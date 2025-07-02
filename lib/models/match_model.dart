enum MatchStatus {
  active,
  archived,
  blocked,
}

class MatchModel {
  final String id;
  final String contributorId;
  final String projectId;
  final String projectOwnerId;
  final DateTime createdAt;
  final MatchStatus status;
  final DateTime? lastMessageAt;
  final int? messageCount;
  final Map<String, dynamic>? metadata;

  const MatchModel({
    required this.id,
    required this.contributorId,
    required this.projectId,
    required this.projectOwnerId,
    required this.createdAt,
    required this.status,
    this.lastMessageAt,
    this.messageCount,
    this.metadata,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      contributorId: json['contributorId'] as String,
      projectId: json['projectId'] as String,
      projectOwnerId: json['projectOwnerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: MatchStatus.values.byName(json['status'] as String),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      messageCount: json['messageCount'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contributorId': contributorId,
      'projectId': projectId,
      'projectOwnerId': projectOwnerId,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messageCount': messageCount,
      'metadata': metadata,
    };
  }

  // Static factory method for easy creation
  static MatchModel create({
    required String contributorId,
    required String projectId,
    required String projectOwnerId,
  }) {
    return MatchModel(
      id: '${contributorId}_${projectId}_${DateTime.now().millisecondsSinceEpoch}',
      contributorId: contributorId,
      projectId: projectId,
      projectOwnerId: projectOwnerId,
      createdAt: DateTime.now(),
      status: MatchStatus.active,
      messageCount: 0,
    );
  }

  bool get isActive => status == MatchStatus.active;
  bool get hasMessages => (messageCount ?? 0) > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
