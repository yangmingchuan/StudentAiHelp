class GrowthReward {
  const GrowthReward({
    required this.id,
    required this.title,
    required this.costStars,
    required this.isActive,
  });

  final int id;
  final String title;
  final int costStars;
  final bool isActive;
}

enum RewardRedemptionStatus {
  pending,
  approved,
  rejected;

  static RewardRedemptionStatus parse(String value) => switch (value) {
    'approved' => approved,
    'rejected' => rejected,
    _ => pending,
  };
}

class GrowthRewardRedemption {
  const GrowthRewardRedemption({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.costStars,
    required this.status,
    required this.requestedAt,
  });

  final int id;
  final int? rewardId;
  final String rewardTitle;
  final int costStars;
  final RewardRedemptionStatus status;
  final DateTime requestedAt;
}

class GrowthRewardsSnapshot {
  const GrowthRewardsSnapshot({
    required this.rewards,
    required this.redemptions,
  });

  final List<GrowthReward> rewards;
  final List<GrowthRewardRedemption> redemptions;

  List<GrowthRewardRedemption> get pendingRedemptions => redemptions
      .where(
        (redemption) => redemption.status == RewardRedemptionStatus.pending,
      )
      .toList();

  bool hasPendingFor(int rewardId) =>
      pendingRedemptions.any((redemption) => redemption.rewardId == rewardId);
}
