"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  RegistrationError,
  initializeDefaultProfileAfterRegistration,
  registerUser,
  validateRegistrationInput,
} = require("../auth_service");

test("accepts a valid MVP registration request", () => {
  assert.deepEqual(
    validateRegistrationInput({
      username: "13800138000",
      password: "Hero2026!",
      privacyAccepted: true,
    }),
    {
      username: "13800138000",
      password: "Hero2026!",
    },
  );
});

test("rejects a password that CloudBase CreateUser would reject", () => {
  assert.throws(
    () =>
      validateRegistrationInput({
        username: "13800138000",
        password: "hero2026",
        privacyAccepted: true,
      }),
    (error) =>
      error instanceof RegistrationError &&
      error.code === "INVALID_PASSWORD",
  );
});

test("creates an internal active CloudBase user", async () => {
  let request;
  const result = await registerUser(
    {
      username: "13800138000",
      password: "Hero2026!",
      privacyAccepted: true,
    },
    {
      env: { CLOUDBASE_ENV_ID: "little-hero-dev-test" },
      client: {
        async CreateUser(params) {
          request = params;
          return { Data: { Uid: "user-1" } };
        },
      },
    },
  );

  assert.equal(request.EnvId, "little-hero-dev-test");
  assert.equal(request.Name, "13800138000");
  assert.equal(request.Type, "internalUser");
  assert.equal(request.UserStatus, "ACTIVE");
  assert.equal(result.uid, "user-1");
  assert.equal(result.phoneOwnershipVerified, false);
  assert.equal(result.profileInitialized, false);
  assert.equal(result.profileInitializationSkipped, true);
});

test("initializes default profile when business API is configured", async () => {
  let request;
  const result = await initializeDefaultProfileAfterRegistration({
    authSubject: "user-1",
    username: "13800138000",
    env: {
      BUSINESS_API_INTERNAL_URL: "https://example.com/api",
      INTERNAL_API_SECRET: "secret",
    },
    fetchImpl: async (url, options) => {
      request = { url, options };
      return { ok: true };
    },
  });

  assert.equal(result.initialized, true);
  assert.equal(result.skipped, false);
  assert.equal(
    request.url,
    "https://example.com/api/internal/parents/default-profile",
  );
  assert.equal(request.options.headers["X-Internal-Secret"], "secret");
  assert.equal(
    JSON.parse(request.options.body).phoneOwnershipVerified,
    false,
  );
});
