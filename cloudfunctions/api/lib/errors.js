"use strict";

class ApiError extends Error {
  constructor(code, message, statusCode = 400, details = undefined) {
    super(message);
    this.name = "ApiError";
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
  }
}

function normalizeError(error) {
  if (error instanceof ApiError) {
    return error;
  }
  return new ApiError(
    "INTERNAL_ERROR",
    "服务暂时不可用，请稍后重试。",
    500,
  );
}

module.exports = { ApiError, normalizeError };
