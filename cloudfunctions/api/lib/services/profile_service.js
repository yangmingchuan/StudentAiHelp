"use strict";

function maskPhone(username) {
  if (!/^1[3-9]\d{9}$/.test(username)) {
    return "";
  }
  return `${username.slice(0, 3)}****${username.slice(7)}`;
}

class ProfileService {
  constructor(repository) {
    this.repository = repository;
  }

  async ensureDefaultProfile({
    authSubject,
    username,
    openid = authSubject,
    phoneOwnershipVerified = false,
    privacyPolicyVersion = "mvp-internal",
    childPrivacyRuleVersion = "mvp-internal",
  }) {
    let parent = await this.repository.findParentBySubject(authSubject);

    if (!parent) {
      parent = await this.repository.saveParent({
        id: this.repository.createId(),
        openid,
        authSubject,
        username,
        phoneMasked: maskPhone(username),
        displayName: "",
        phoneOwnershipVerified,
        privacyPolicyVersion,
        childPrivacyRuleVersion,
        consentAt: new Date().toISOString(),
      });
    }

    let child = await this.repository.findActiveChild(parent.id);
    let createdChild = false;

    if (!child) {
      child = await this.repository.saveChild({
        id: this.repository.createId(),
        openid,
        parentId: parent.id,
        nickname: "小勇士",
        gender: "unknown",
        ageStage: "5-6",
        avatarConfig: {
          icon: "face_rounded",
          color: "green",
        },
        level: 1,
        experience: 0,
        isActive: true,
        needsProfileSetup: true,
      });
      await this.repository.saveSettings({
        id: this.repository.createId(),
        openid,
        childId: child.id,
        timezone: "Asia/Shanghai",
        dailyHeartLimit: 10,
        parentGateEnabled: true,
        soundEnabled: true,
        musicEnabled: true,
        maxDailyLearningMinutes: 30,
      });
      await this.repository.createDefaultHabits({ openid, childId: child.id });
      createdChild = true;
    }

    return {
      parent,
      child,
      createdChild,
    };
  }
}

module.exports = { ProfileService, maskPhone };
