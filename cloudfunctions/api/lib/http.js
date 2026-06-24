"use strict";

const { ApiError, normalizeError } = require("./errors");

const MAX_BODY_BYTES = 64 * 1024;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "Authorization, Content-Type, X-Internal-Secret, X-Operation-Id, X-Request-Id",
  "Cache-Control": "no-store",
};

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    ...CORS_HEADERS,
    "Content-Type": "application/json; charset=utf-8",
  });
  res.end(JSON.stringify(data));
}

function sendOptions(res) {
  res.writeHead(204, CORS_HEADERS);
  res.end();
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let raw = "";
    let size = 0;

    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        reject(new ApiError("REQUEST_TOO_LARGE", "请求内容过大。", 413));
        req.destroy();
        return;
      }
      raw += chunk;
    });

    req.on("end", () => {
      if (!raw) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(raw));
      } catch {
        reject(new ApiError("INVALID_JSON", "请求格式不正确。", 400));
      }
    });

    req.on("error", reject);
  });
}

async function handleRoute(req, res, handler) {
  try {
    const result = await handler();
    sendJson(res, result.statusCode || 200, result.body || {});
  } catch (error) {
    const normalized = normalizeError(error);
    if (normalized.statusCode >= 500) {
      console.error("API request failed", {
        code: normalized.code,
        name: error?.name || "Error",
      });
    }
    sendJson(res, normalized.statusCode, {
      code: normalized.code,
      message: normalized.message,
      ...(normalized.details ? { details: normalized.details } : {}),
    });
  }
}

module.exports = {
  CORS_HEADERS,
  readJsonBody,
  sendJson,
  sendOptions,
  handleRoute,
};
