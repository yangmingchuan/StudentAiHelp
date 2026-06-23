"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {
  RegistrationError,
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
});
