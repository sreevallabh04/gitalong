class BadgeModel {
  final String id;
  final String userId;
  final BadgeType badgeType;
  final DateTime awardedAt;
  final String? description;

  const BadgeModel({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.awardedAt,
    this.description,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeType: BadgeType.values.byName(json['badge_type'] as String),
      awardedAt: DateTime.parse(json['awarded_at'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_type': badgeType.name,
      'awarded_at': awardedAt.toIso8601String(),
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BadgeModel{id: $id, userId: $userId, badgeType: $badgeType}';
  }
}

enum BadgeType {
  firstMatch,
  fiveMatches,
  tenMatches,
  firstPr,
  fivePrs,
  tenPrs,
  streakWarrior,
  openSourceHero,
  earlyAdopter,
}
