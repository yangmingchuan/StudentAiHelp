"use strict";

const { ApiError } = require("../errors");
const { formatDateInTimeZone } = require("../date");
const { BootstrapService } = require("./bootstrap_service");

class TaskRecordService {
  constructor(repository) {
    this.repository = repository;
    this.bootstrapService = new BootstrapService(repository);
  }

  async recordTask(identity, body, now = new Date()) {
    const operationId = requireString(body.operationId, "operationId");
    const childId = requireNumber(body.childId, "childId");
    const taskId = requireNumber(body.taskId, "taskId");
    const status = requireStatus(body.status);

    return this.repository.runIdempotent(
      {
        operationId,
        operationType: "task_status",
        actorSubject: identity.subject,
      },
      async () => {
        const profile = await this.bootstrapService.bootstrap(identity, now);
        if (profile.child.id !== childId) {
          throw new ApiError("FORBIDDEN", "无权修改该孩子数据。", 403);
        }

        const date = formatDateInTimeZone(now, profile.timezone);
        const oldFull = await this.repository.isFullCompletionDay(childId, date);
        const oldRecord = await this.repository.findHabitRecord({
          childId,
          habitId: taskId,
          recordDate: date,
        });
        const oldStatus = oldRecord?.status || "none";
        const appliedStatus = oldStatus === status ? "none" : status;

        await this.repository.saveHabitRecord({
          childId,
          habitId: taskId,
          recordDate: date,
          status: appliedStatus,
          operationId,
        });

        const taskDelta = statusStarValue(appliedStatus) - statusStarValue(oldStatus);
        if (taskDelta !== 0) {
          await this.repository.changeStars(childId, taskDelta);
        }

        const newFull = await this.repository.isFullCompletionDay(childId, date);
        await this.repository.applyDailyAward({
          childId,
          awardDate: date,
          awardType: "full_completion",
          stars: 2,
          shouldExist: newFull,
        });

        const hasSevenDayStreak =
          newFull &&
          (await this.repository.hasFullCompletionStreak(childId, date, 7));
        await this.repository.applyDailyAward({
          childId,
          awardDate: date,
          awardType: "seven_day_streak",
          stars: 5,
          shouldExist: hasSevenDayStreak,
        });

        await this.repository.issueEligibleBadges(childId, date);
        return {
          record: {
            childId,
            taskId,
            recordDate: date,
            status: appliedStatus,
          },
          snapshot: await this.bootstrapService.bootstrap(identity, now),
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

function requireStatus(value) {
  if (value === "done" || value === "skipped" || value === "none") {
    return value;
  }
  throw new ApiError("INVALID_REQUEST", "任务状态不正确。", 400);
}

function statusStarValue(status) {
  return status === "done" ? 1 : 0;
}

module.exports = { TaskRecordService };
