"use strict";

const { formatDateInTimeZone } = require("../date");
const { ProfileService } = require("./profile_service");

class BootstrapService {
  constructor(repository) {
    this.repository = repository;
    this.profileService = new ProfileService(repository);
  }

  async bootstrap(identity, now = new Date()) {
    const { parent, child } = await this.profileService.ensureDefaultProfile({
      authSubject: identity.subject,
      username: identity.username,
      openid: identity.openid || identity.subject,
    });
    const settings = await this.repository.findSettings(child.id);
    const timezone = settings?.timezone || "Asia/Shanghai";
    const serverDate = formatDateInTimeZone(now, timezone);
    const habits = await this.repository.listActiveHabits(child.id);
    const records = await this.repository.listHabitRecords({
      childId: child.id,
      recordDate: serverDate,
    });
    const recordByHabit = new Map(
      records.map((record) => [record.habitId, record]),
    );
    const assets = await this.repository.ensureAssetSnapshot({
      openid: identity.openid || identity.subject,
      childId: child.id,
      snapshotDate: serverDate,
    });
    const badges = await this.repository.listBadges(child.id);

    return {
      serverDate,
      timezone,
      syncCursor: null,
      parent: {
        id: parent.id,
        username: parent.username,
        phoneMasked: parent.phoneMasked,
        phoneOwnershipVerified: parent.phoneOwnershipVerified,
      },
      child: {
        id: child.id,
        nickname: child.nickname,
        gender: child.gender,
        ageStage: child.ageStage,
        avatarConfig: child.avatarConfig,
        needsProfileSetup: child.needsProfileSetup === true,
      },
      assets: {
        availableStars: assets.availableStars,
        lifetimeStars: assets.lifetimeStars,
        badgeCount: badges.length || assets.badgeCount,
        hearts: {
          remaining: assets.todayHeartsRemaining,
          limit: assets.todayHeartsLimit,
        },
      },
      todayTasks: habits.map((habit) => {
        const record = recordByHabit.get(habit.id);
        return {
          id: habit.id,
          name: habit.name,
          iconName: habit.iconName,
          sortOrder: habit.sortOrder,
          status: record?.status || "none",
          recordId: record?.id || null,
        };
      }),
      badges: {
        earnedCount: badges.length,
        totalCount: 3,
        recent: badges.slice(0, 3),
      },
    };
  }
}

module.exports = { BootstrapService };
