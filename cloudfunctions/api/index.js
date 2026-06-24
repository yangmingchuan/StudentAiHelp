"use strict";

const http = require("http");
const { URL } = require("url");
const { createAuthVerifier, assertInternalSecret } = require("./lib/auth");
const { handleRoute, readJsonBody, sendOptions, sendJson } = require("./lib/http");
const { ApiError } = require("./lib/errors");
const { MemoryRepository } = require("./lib/repositories/memory_repository");
const { ProfileService } = require("./lib/services/profile_service");
const { BootstrapService } = require("./lib/services/bootstrap_service");
const { TaskRecordService } = require("./lib/services/task_record_service");
const { TaskManagementService } = require("./lib/services/task_management_service");

function requireString(value, fieldName) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new ApiError("INVALID_REQUEST", `${fieldName} 不能为空。`, 400);
  }
  return value.trim();
}

function createServer({
  repository = new MemoryRepository(),
  env = process.env,
  authVerifier = createAuthVerifier({ env }),
} = {}) {
  const profileService = new ProfileService(repository);
  const bootstrapService = new BootstrapService(repository);
  const taskRecordService = new TaskRecordService(repository);
  const taskManagementService = new TaskManagementService(repository);

  return http.createServer(async (req, res) => {
    if (req.method === "OPTIONS") {
      sendOptions(res);
      return;
    }

    const url = new URL(req.url || "/", "http://127.0.0.1");

    if (req.method === "GET" && url.pathname === "/health") {
      sendJson(res, 200, { ok: true });
      return;
    }

    if (req.method === "POST" && url.pathname === "/internal/parents/default-profile") {
      await handleRoute(req, res, async () => {
        assertInternalSecret(req, env);
        const body = await readJsonBody(req);
        const result = await profileService.ensureDefaultProfile({
          authSubject: requireString(body.authSubject, "authSubject"),
          username: requireString(body.username, "username"),
          openid: body.openid || body.authSubject,
          phoneOwnershipVerified: body.phoneOwnershipVerified === true,
          privacyPolicyVersion: body.privacyPolicyVersion,
          childPrivacyRuleVersion: body.childPrivacyRuleVersion,
        });

        return {
          statusCode: result.createdChild ? 201 : 200,
          body: {
            data: {
              parentId: result.parent.id,
              childId: result.child.id,
              createdChild: result.createdChild,
            },
          },
        };
      });
      return;
    }

    if (req.method === "GET" && url.pathname === "/api/bootstrap") {
      await handleRoute(req, res, async () => {
        const identity = await authVerifier.verify(req);
        const data = await bootstrapService.bootstrap(identity);
        return { body: { data } };
      });
      return;
    }

    if (req.method === "POST" && url.pathname === "/api/tasks/record") {
      await handleRoute(req, res, async () => {
        const identity = await authVerifier.verify(req);
        const body = await readJsonBody(req);
        const data = await taskRecordService.recordTask(identity, body);
        return { body: { data } };
      });
      return;
    }

    if (req.method === "POST" && url.pathname === "/api/tasks/manage") {
      await handleRoute(req, res, async () => {
        const identity = await authVerifier.verify(req);
        const body = await readJsonBody(req);
        const data = await taskManagementService.manage(identity, body);
        return { body: { data } };
      });
      return;
    }

    if (
      url.pathname === "/api/bootstrap" ||
      url.pathname === "/api/tasks/record" ||
      url.pathname === "/api/tasks/manage"
    ) {
      sendJson(res, 405, {
        code: "METHOD_NOT_ALLOWED",
        message: "Method Not Allowed",
      });
      return;
    }

    sendJson(res, 404, {
      code: "NOT_FOUND",
      message: "Not Found",
    });
  });
}

if (require.main === module) {
  createServer().listen(9000, "0.0.0.0");
}

module.exports = { createServer };
