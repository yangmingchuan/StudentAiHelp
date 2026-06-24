"use strict";

const PHONE_USERNAME_PATTERN = /^1[3-9]\d{9}$/;
const ALLOWED_SPECIAL_PATTERN = /[()!@#$%^&*|?><_-]/;
const PASSWORD_ALLOWED_PATTERN = /^[A-Za-z0-9()!@#$%^&*|?><_-]+$/;

class RegistrationError extends Error {
  constructor(code, message, statusCode = 400) {
    super(message);
    this.name = "RegistrationError";
    this.code = code;
    this.statusCode = statusCode;
  }
}

function validateRegistrationInput(body) {
  const username =
    typeof body?.username === "string" ? body.username.trim() : "";
  const password = typeof body?.password === "string" ? body.password : "";
  const privacyAccepted = body?.privacyAccepted === true;

  if (!PHONE_USERNAME_PATTERN.test(username)) {
    throw new RegistrationError(
      "INVALID_USERNAME",
      "请输入合法的 11 位中国大陆手机号格式账号。",
    );
  }

  if (password.length < 8 || password.length > 20) {
    throw new RegistrationError(
      "INVALID_PASSWORD",
      "密码长度需为 8-20 位。",
    );
  }

  if (!/^[A-Za-z0-9]/.test(password)) {
    throw new RegistrationError(
      "INVALID_PASSWORD",
      "密码不能以特殊字符开头。",
    );
  }

  if (!PASSWORD_ALLOWED_PATTERN.test(password)) {
    throw new RegistrationError(
      "INVALID_PASSWORD",
      "密码包含不支持的字符。",
    );
  }

  const categoryCount = [
    /[a-z]/.test(password),
    /[A-Z]/.test(password),
    /\d/.test(password),
    ALLOWED_SPECIAL_PATTERN.test(password),
  ].filter(Boolean).length;

  if (categoryCount < 3) {
    throw new RegistrationError(
      "INVALID_PASSWORD",
      "密码需包含小写字母、大写字母、数字、特殊字符中的至少三类。",
    );
  }

  if (!privacyAccepted) {
    throw new RegistrationError(
      "PRIVACY_NOT_ACCEPTED",
      "请先阅读并同意隐私政策和儿童个人信息保护规则。",
    );
  }

  return { username, password };
}

function createTcbUserClient({ env = process.env } = {}) {
  const secretId = env.TENCENTCLOUD_SECRETID;
  const secretKey = env.TENCENTCLOUD_SECRETKEY;
  const token = env.TENCENTCLOUD_SESSIONTOKEN;

  if (!secretId || !secretKey) {
    throw new RegistrationError(
      "SERVER_NOT_CONFIGURED",
      "注册服务暂不可用，请联系内测管理员。",
      503,
    );
  }

  const { tcb } = require("tencentcloud-sdk-nodejs-tcb");
  const TcbClient = tcb.v20180608.Client;

  return new TcbClient({
    credential: { secretId, secretKey, token },
    region: env.TENCENTCLOUD_REGION || "ap-shanghai",
    profile: {
      signMethod: "TC3-HMAC-SHA256",
      httpProfile: {
        endpoint: "tcb.tencentcloudapi.com",
        reqMethod: "POST",
        reqTimeout: 10,
      },
    },
  });
}

async function registerUser(body, { client, env = process.env } = {}) {
  const { username, password } = validateRegistrationInput(body);
  const envId = env.CLOUDBASE_ENV_ID;

  if (!envId) {
    throw new RegistrationError(
      "SERVER_NOT_CONFIGURED",
      "注册服务暂不可用，请联系内测管理员。",
      503,
    );
  }

  const tcbClient = client || createTcbUserClient({ env });

  try {
    const response = await tcbClient.CreateUser({
      EnvId: envId,
      Name: username,
      Type: "internalUser",
      Password: password,
      UserStatus: "ACTIVE",
      Description: "Little Hero MVP parent account; phone ownership unverified",
    });

    const result = {
      uid: response?.Data?.Uid || "",
      username,
      phoneOwnershipVerified: false,
    };

    const profileResult = await initializeDefaultProfileAfterRegistration({
      authSubject: result.uid,
      username,
      env,
    });

    return {
      ...result,
      profileInitialized: profileResult.initialized,
      profileInitializationSkipped: profileResult.skipped,
    };
  } catch (error) {
    if (error instanceof RegistrationError) {
      throw error;
    }

    const errorCode = error?.code || error?.Code || "";

    if (
      errorCode === "FailedOperation.DuplicatedData" ||
      /duplicate|already exists/i.test(error?.message || "")
    ) {
      throw new RegistrationError(
        "USERNAME_ALREADY_EXISTS",
        "该账号已注册，请直接登录。",
        409,
      );
    }

    console.error("CreateUser failed", {
      code: errorCode || "UNKNOWN",
      requestId: error?.requestId || error?.RequestId || "",
    });

    throw new RegistrationError(
      "REGISTRATION_FAILED",
      "注册暂时失败，请稍后重试。",
      502,
    );
  }
}

async function initializeDefaultProfileAfterRegistration({
  authSubject,
  username,
  env = process.env,
  fetchImpl = fetch,
}) {
  const baseUrl = env.BUSINESS_API_INTERNAL_URL;
  const internalSecret = env.INTERNAL_API_SECRET;

  if (!baseUrl || !internalSecret || !authSubject) {
    return { initialized: false, skipped: true };
  }

  const response = await fetchImpl(
    `${baseUrl.replace(/\/$/, "")}/internal/parents/default-profile`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Internal-Secret": internalSecret,
      },
      body: JSON.stringify({
        authSubject,
        username,
        phoneOwnershipVerified: false,
        privacyPolicyVersion: "mvp-internal",
        childPrivacyRuleVersion: "mvp-internal",
      }),
    },
  );

  if (!response.ok) {
    throw new RegistrationError(
      "PROFILE_INITIALIZATION_FAILED",
      "账号已创建，但默认孩子档案初始化失败，请联系内测管理员。",
      502,
    );
  }

  return { initialized: true, skipped: false };
}

module.exports = {
  RegistrationError,
  initializeDefaultProfileAfterRegistration,
  registerUser,
  validateRegistrationInput,
};
