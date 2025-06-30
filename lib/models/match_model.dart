class MatchModel {
  final String id;
  final String contributorId;
  final String projectId;
  final DateTime createdAt;
  final MatchStatus status;

  const MatchModel({
    required this.id,
    required this.contributorId,
    required this.projectId,
    required this.createdAt,
    this.status = MatchStatus.active,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      contributorId: json['contributor_id'] as String,
      projectId: json['project_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: MatchStatus.values.byName(json['status'] ?? 'active'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contributor_id': contributorId,
      'project_id': projectId,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  MatchModel copyWith({
    String? id,
    String? contributorId,
    String? projectId,
    DateTime? createdAt,
    MatchStatus? status,
  }) {
    return MatchModel(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MatchModel{id: $id, contributorId: $contributorId, projectId: $projectId}';
  }
}

enum MatchStatus { active, inactive, completed }
