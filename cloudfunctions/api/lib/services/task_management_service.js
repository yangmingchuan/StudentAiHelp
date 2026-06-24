"use strict";

const { ApiError } = require("../errors");
const { BootstrapService } = require("./bootstrap_service");

class TaskManagementService {
  constructor(repository) {
    this.repository = repository;
    this.bootstrapService = new BootstrapService(repository);
  }

  async manage(identity, body) {
    const operationId = requireString(body.operationId, "operationId");
    const action = requireString(body.action, "action");

    return this.repository.runIdempotent(
      {
        operationId,
        operationType: `task_${action}`,
        actorSubject: identity.subject,
      },
      async () => {
        const snapshot = await this.bootstrapService.bootstrap(identity);
        const childId = snapshot.child.id;

        if (action === "create") {
          const taskId = requireNumber(body.taskId, "taskId");
          const name = requireTaskName(body.name);
          await this.repository.saveHabit({
            id: taskId,
            openid: identity.openid || identity.subject,
            childId,
            templateCode: "",
            name,
            iconName: "task_alt_rounded",
            category: "custom",
            isActive: true,
            sortOrder: Number(body.sortOrder) || 999,
          });
        } else if (action === "update") {
          const taskId = requireNumber(body.taskId, "taskId");
          const name = requireTaskName(body.name);
          await this.repository.updateHabit(taskId, { name });
        } else if (action === "delete") {
          const taskId = requireNumber(body.taskId, "taskId");
          await this.repository.updateHabit(taskId, {
            isActive: false,
            deletedAt: new Date().toISOString(),
          });
        } else if (action === "reorder") {
          if (!Array.isArray(body.taskIds)) {
            throw new ApiError("INVALID_REQUEST", "taskIds 不正确。", 400);
          }
          await this.repository.reorderHabits(
            body.taskIds.map((id) => requireNumber(id, "taskId")),
          );
        } else {
          throw new ApiError("INVALID_REQUEST", "任务操作不正确。", 400);
        }

        return {
          snapshot: await this.bootstrapService.bootstrap(identity),
        };
      },
    );
  }
}

function requireString(value, fieldName) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new ApiError("INVALID_REQUEST", `${fieldName} 不能为空。`, 400);
  }
  return value.trim();
}

function requireNumber(value, fieldName) {
  const number = typeof value === "number" ? value : Number.parseInt(value, 10);
  if (!Number.isInteger(number) || number <= 0) {
    throw new ApiError("INVALID_REQUEST", `${fieldName} 不正确。`, 400);
  }
  return number;
}

function requireTaskName(value) {
  const name = requireString(value, "name");
  const length = Array.from(name).reduce(
    (sum, char) => sum + (char.charCodeAt(0) > 255 ? 1 : 0.5),
    0,
  );
  if (length > 7) {
    throw new ApiError("INVALID_REQUEST", "任务名称最多 7 个汉字。", 400);
  }
  return name;
}

module.exports = { TaskManagementService };
