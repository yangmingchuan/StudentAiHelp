"use strict";

const DEFAULT_HABIT_TEMPLATES = [
  {
    code: "brush_teeth",
    name: "自己刷牙",
    iconName: "clean_hands_rounded",
    category: "daily_care",
    sortOrder: 10,
  },
  {
    code: "make_bed",
    name: "整理床铺",
    iconName: "bed_rounded",
    category: "daily_care",
    sortOrder: 20,
  },
  {
    code: "read_book",
    name: "阅读绘本",
    iconName: "auto_stories_rounded",
    category: "learning",
    sortOrder: 30,
  },
];

class MemoryRepository {
  constructor() {
    this.nextId = 1;
    this.parents = new Map();
    this.children = new Map();
    this.settings = new Map();
    this.habits = new Map();
    this.records = new Map();
    this.assetSnapshots = new Map();
    this.badges = new Map();
    this.dailyAwards = new Map();
    this.idempotency = new Map();
  }

  createId() {
    const id = this.nextId;
    this.nextId += 1;
    return id;
  }

  async runIdempotent(operation, handler) {
    if (!operation?.operationId) {
      return handler();
    }

    const cached = this.idempotency.get(operation.operationId);
    if (cached) {
      return cached.responsePayload;
    }

    const responsePayload = await handler();
    this.idempotency.set(operation.operationId, {
      ...operation,
      status: "succeeded",
      responsePayload,
      createdAt: new Date().toISOString(),
    });
    return responsePayload;
  }

  async findParentBySubject(authSubject) {
    return this.parents.get(authSubject) || null;
  }

  async saveParent(parent) {
    this.parents.set(parent.authSubject, parent);
    return parent;
  }

  async findActiveChild(parentId) {
    for (const child of this.children.values()) {
      if (child.parentId === parentId && child.isActive) {
        return child;
      }
    }
    return null;
  }

  async saveChild(child) {
    this.children.set(child.id, child);
    return child;
  }

  async saveSettings(settings) {
    this.settings.set(settings.childId, settings);
    return settings;
  }

  async findSettings(childId) {
    return this.settings.get(childId) || null;
  }

  async createDefaultHabits({ openid, childId }) {
    const existing = await this.listActiveHabits(childId);
    if (existing.length > 0) {
      return existing;
    }

    for (const template of DEFAULT_HABIT_TEMPLATES) {
      const habit = {
        id: this.createId(),
        openid,
        childId,
        templateCode: template.code,
        name: template.name,
        iconName: template.iconName,
        category: template.category,
        isActive: true,
        sortOrder: template.sortOrder,
      };
      this.habits.set(habit.id, habit);
    }
    return this.listActiveHabits(childId);
  }

  async listActiveHabits(childId) {
    return Array.from(this.habits.values())
      .filter((habit) => habit.childId === childId && habit.isActive)
      .sort((a, b) => a.sortOrder - b.sortOrder || a.id - b.id);
  }

  async saveHabit(habit) {
    this.habits.set(habit.id, habit);
    return habit;
  }

  async updateHabit(habitId, patch) {
    const habit = this.habits.get(habitId);
    if (!habit) {
      return null;
    }
    const updated = { ...habit, ...patch };
    this.habits.set(habitId, updated);
    return updated;
  }

  async reorderHabits(taskIds) {
    taskIds.forEach((taskId, index) => {
      const habit = this.habits.get(taskId);
      if (habit) {
        this.habits.set(taskId, {
          ...habit,
          sortOrder: (index + 1) * 10,
        });
      }
    });
  }

  async listHabitRecords({ childId, recordDate }) {
    return Array.from(this.records.values()).filter(
      (record) => record.childId === childId && record.recordDate === recordDate,
    );
  }

  async findHabitRecord({ childId, habitId, recordDate }) {
    return (
      this.records.get(`${childId}:${habitId}:${recordDate}`) || null
    );
  }

  async saveHabitRecord(record) {
    const key = `${record.childId}:${record.habitId}:${record.recordDate}`;
    const existing = this.records.get(key);
    const saved = {
      id: existing?.id || this.createId(),
      ...existing,
      ...record,
      updatedAt: new Date().toISOString(),
    };
    this.records.set(key, saved);
    return saved;
  }

  async isFullCompletionDay(childId, recordDate) {
    const habits = await this.listActiveHabits(childId);
    if (habits.length === 0) {
      return false;
    }
    return habits.every((habit) => {
      const record = this.records.get(`${childId}:${habit.id}:${recordDate}`);
      return record?.status === "done";
    });
  }

  async hasFullCompletionStreak(childId, today, days) {
    const date = new Date(`${today}T00:00:00Z`);
    for (let offset = 0; offset < days; offset += 1) {
      const current = new Date(date);
      current.setUTCDate(current.getUTCDate() - offset);
      const day = current.toISOString().slice(0, 10);
      if (!(await this.isFullCompletionDay(childId, day))) {
        return false;
      }
    }
    return true;
  }

  async ensureAssetSnapshot({ openid, childId, snapshotDate }) {
    const key = `${childId}:${snapshotDate}`;
    const existing = this.assetSnapshots.get(key);
    if (existing) {
      return existing;
    }

    const snapshot = {
      id: this.createId(),
      openid,
      childId,
      availableStars: 0,
      lifetimeStars: 0,
      badgeCount: 0,
      todayHeartsRemaining: 10,
      todayHeartsLimit: 10,
      snapshotDate,
    };
    this.assetSnapshots.set(key, snapshot);
    return snapshot;
  }

  async changeStars(childId, delta) {
    const child = this.children.get(childId);
    const snapshotDate = new Date().toISOString().slice(0, 10);
    const snapshot = await this.ensureAssetSnapshot({
      openid: child?.openid || "",
      childId,
      snapshotDate,
    });
    snapshot.availableStars = Math.max(0, snapshot.availableStars + delta);
    snapshot.lifetimeStars = Math.max(0, snapshot.lifetimeStars + delta);
    return snapshot;
  }

  async applyDailyAward({ childId, awardDate, awardType, stars, shouldExist }) {
    const key = `${childId}:${awardDate}:${awardType}`;
    const exists = this.dailyAwards.has(key);
    if (shouldExist && !exists) {
      this.dailyAwards.set(key, { childId, awardDate, awardType, stars });
      await this.changeStars(childId, stars);
    } else if (!shouldExist && exists) {
      this.dailyAwards.delete(key);
      await this.changeStars(childId, -stars);
    }
  }

  async issueEligibleBadges(childId, earnedDate) {
    const snapshot = await this.ensureAssetSnapshot({
      openid: this.children.get(childId)?.openid || "",
      childId,
      snapshotDate: earnedDate,
    });
    if (snapshot.lifetimeStars >= 1) {
      await this.issueBadge(childId, "first_star", "第一颗星", earnedDate);
    }
    const fullDayKey = `${childId}:${earnedDate}:full_completion`;
    if (this.dailyAwards.has(fullDayKey)) {
      await this.issueBadge(childId, "three_done_day", "全完成日", earnedDate);
    }
    const streakKey = `${childId}:${earnedDate}:seven_day_streak`;
    if (this.dailyAwards.has(streakKey)) {
      await this.issueBadge(childId, "seven_day_streak", "七天勇士", earnedDate);
    }
  }

  async issueBadge(childId, code, name, earnedDate) {
    const key = `${childId}:${code}`;
    if (this.badges.has(key)) {
      return;
    }
    this.badges.set(key, {
      childId,
      code,
      name,
      iconName: "workspace_premium_rounded",
      earnedDate,
    });
  }

  async listBadges(childId) {
    return Array.from(this.badges.values()).filter(
      (badge) => badge.childId === childId,
    );
  }
}

module.exports = { MemoryRepository, DEFAULT_HABIT_TEMPLATES };
