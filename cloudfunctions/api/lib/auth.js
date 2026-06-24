"use strict";

const { ApiError } = require("./errors");

function getBearerToken(req) {
  const header = req.headers.authorization || "";
  const match = /^Bearer\s+(.+)$/i.exec(header);
  return match?.[1] || "";
}

function createAuthVerifier({ env = process.env } = {}) {
  return {
    async verify(req) {
      const token = getBearerToken(req);
      if (!token) {
        throw new ApiError("UNAUTHORIZED", "请先登录。", 401);
      }

      if (env.NODE_ENV === "test" && token.startsWith("test:")) {
        const [, subject, username] = token.split(":");
        return {
          subject: subject || "test-user",
          username: username || "13800138000",
          openid: subject || "test-user",
        };
      }

      if (!env.AUTH_USERINFO_URL) {
        throw new ApiError(
          "AUTH_VERIFIER_NOT_CONFIGURED",
          "登录校验服务尚未配置。",
          503,
        );
      }

      const response = await fetch(env.AUTH_USERINFO_URL, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: "application/json",
        },
      });

      if (response.status === 401 || response.status === 403) {
        throw new ApiError("UNAUTHORIZED", "登录已失效，请重新登录。", 401);
      }
      if (!response.ok) {
        throw new ApiError(
          "AUTH_VERIFICATION_FAILED",
          "登录校验失败，请稍后重试。",
          502,
        );
      }

      const data = await response.json();
      const subject = data.sub || data.userId || data.uid || "";
      if (!subject) {
        throw new ApiError(
          "INVALID_AUTH_RESPONSE",
          "登录校验服务返回了无效身份。",
          502,
        );
      }

      return {
        subject: String(subject),
        username: String(data.username || data.name || ""),
        openid: String(data.openid || subject),
      };
    },
  };
}

function assertInternalSecret(req, env = process.env) {
  const expected = env.INTERNAL_API_SECRET;
  if (!expected) {
    throw new ApiError(
      "INTERNAL_SECRET_NOT_CONFIGURED",
      "内部接口密钥尚未配置。",
      503,
    );
  }

  if (req.headers["x-internal-secret"] !== expected) {
    throw new ApiError("FORBIDDEN", "无权访问该接口。", 403);
  }
}

module.exports = { createAuthVerifier, assertInternalSecret, getBearerToken };
