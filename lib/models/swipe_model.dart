class SwipeModel {
  final String id;
  final String swiperId;
  final String targetId;
  final SwipeDirection direction;
  final SwipeTargetType targetType;
  final DateTime createdAt;

  const SwipeModel({
    required this.id,
    required this.swiperId,
    required this.targetId,
    required this.direction,
    required this.targetType,
    required this.createdAt,
  });

  factory SwipeModel.fromJson(Map<String, dynamic> json) {
    return SwipeModel(
      id: json['id'] as String,
      swiperId: json['swiper_id'] as String,
      targetId: json['target_id'] as String,
      direction: SwipeDirection.values.byName(json['direction'] as String),
      targetType: SwipeTargetType.values.byName(json['target_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'swiper_id': swiperId,
      'target_id': targetId,
      'direction': direction.name,
      'target_type': targetType.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwipeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SwipeModel{id: $id, swiperId: $swiperId, targetId: $targetId, direction: $direction}';
  }
}

enum SwipeDirection { left, right }

enum SwipeTargetType { user, project }
