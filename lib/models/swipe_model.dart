enum SwipeTargetType {
  user,
  project,
}

class SwipeModel {
  final String id;
  final String swiperId;
  final String targetId;
  final SwipeTargetType targetType;
  final bool isLike;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const SwipeModel({
    required this.id,
    required this.swiperId,
    required this.targetId,
    required this.targetType,
    required this.isLike,
    required this.createdAt,
    this.metadata,
  });

  factory SwipeModel.fromJson(Map<String, dynamic> json) {
    return SwipeModel(
      id: json['id'] as String,
      swiperId: json['swiperId'] as String,
      targetId: json['targetId'] as String,
      targetType: SwipeTargetType.values.byName(json['targetType'] as String),
      isLike: json['isLike'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'swiperId': swiperId,
      'targetId': targetId,
      'targetType': targetType.name,
      'isLike': isLike,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Static factory methods for easy creation
  static SwipeModel createUserSwipe({
    required String swiperId,
    required String targetUserId,
    required bool isLike,
  }) {
    return SwipeModel(
      id: '${swiperId}_${targetUserId}_${DateTime.now().millisecondsSinceEpoch}',
      swiperId: swiperId,
      targetId: targetUserId,
      targetType: SwipeTargetType.user,
      isLike: isLike,
      createdAt: DateTime.now(),
    );
  }

  static SwipeModel createProjectSwipe({
    required String swiperId,
    required String targetProjectId,
    required bool isLike,
  }) {
    return SwipeModel(
      id: '${swiperId}_${targetProjectId}_${DateTime.now().millisecondsSinceEpoch}',
      swiperId: swiperId,
      targetId: targetProjectId,
      targetType: SwipeTargetType.project,
      isLike: isLike,
      createdAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwipeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
