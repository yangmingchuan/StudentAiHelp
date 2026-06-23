"use strict";

const http = require("http");
const { URL } = require("url");
const {
  RegistrationError,
  registerUser,
} = require("./auth_service");

const MAX_BODY_BYTES = 8 * 1024;
const RATE_LIMIT_WINDOW_MS = 60 * 1000;
const RATE_LIMIT_MAX_REQUESTS = 5;
const attemptsByIp = new Map();

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "Content-Type, X-Request-Id, X-Device-Id",
  "Cache-Control": "no-store",
};

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    ...CORS_HEADERS,
    "Content-Type": "application/json; charset=utf-8",
  });
  res.end(JSON.stringify(data));
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let raw = "";
    let size = 0;

    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        reject(
          new RegistrationError(
            "REQUEST_TOO_LARGE",
            "请求内容过大。",
            413,
          ),
        );
        req.destroy();
        return;
      }
      raw += chunk;
    });

    req.on("end", () => {
      if (!raw) {
        reject(
          new RegistrationError(
            "INVALID_REQUEST",
            "请求内容不能为空。",
          ),
        );
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch {
        reject(
          new RegistrationError(
            "INVALID_JSON",
            "请求格式不正确。",
          ),
        );
      }
    });

    req.on("error", reject);
  });
}

function getClientIp(req) {
  const forwarded = req.headers["x-forwarded-for"];
  if (typeof forwarded === "string" && forwarded.length > 0) {
    return forwarded.split(",")[0].trim();
  }
  return req.socket.remoteAddress || "unknown";
}

function checkRateLimit(req) {
  const now = Date.now();
  const ip = getClientIp(req);
  const current = attemptsByIp.get(ip);

  if (!current || now - current.startedAt >= RATE_LIMIT_WINDOW_MS) {
    attemptsByIp.set(ip, { count: 1, startedAt: now });
    return;
  }

  current.count += 1;
  if (current.count > RATE_LIMIT_MAX_REQUESTS) {
    throw new RegistrationError(
      "RATE_LIMITED",
      "尝试次数过多，请稍后再试。",
      429,
    );
  }
}

function isRegistrationPath(pathname) {
  return ["/", "/register", "/api/auth/register"].includes(pathname);
}

function createServer({ register = registerUser } = {}) {
  return http.createServer(async (req, res) => {
    if (req.method === "OPTIONS") {
      res.writeHead(204, CORS_HEADERS);
      res.end();
      return;
    }

    const url = new URL(req.url || "/", "http://127.0.0.1");

    if (req.method === "GET" && url.pathname === "/health") {
      sendJson(res, 200, { ok: true });
      return;
    }

    if (isRegistrationPath(url.pathname) && req.method !== "POST") {
      sendJson(res, 405, {
        code: "METHOD_NOT_ALLOWED",
        message: "Method Not Allowed",
      });
      return;
    }

    if (!isRegistrationPath(url.pathname)) {
      sendJson(res, 404, {
        code: "NOT_FOUND",
        message: "Not Found",
      });
      return;
    }

    try {
      checkRateLimit(req);
      const body = await readJsonBody(req);
      const result = await register(body);
      sendJson(res, 201, { data: result });
    } catch (error) {
      if (error instanceof RegistrationError) {
        sendJson(res, error.statusCode, {
          code: error.code,
          message: error.message,
        });
        return;
      }

      console.error("Unexpected registration error", {
        name: error?.name || "Error",
      });
      sendJson(res, 500, {
        code: "INTERNAL_ERROR",
        message: "服务暂时不可用，请稍后重试。",
      });
    }
  });
}

if (require.main === module) {
  createServer().listen(9000, "0.0.0.0");
}

module.exports = { createServer };
