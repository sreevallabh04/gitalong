class ContributionModel {
  final String id;
  final String userId;
  final String projectId;
  final ContributionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? prUrl;
  final String? description;

  const ContributionModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.prUrl,
    this.description,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String,
      status: ContributionStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      prUrl: json['pr_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pr_url': prUrl,
      'description': description,
    };
  }

  ContributionModel copyWith({
    String? id,
    String? userId,
    String? projectId,
    ContributionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? prUrl,
    String? description,
  }) {
    return ContributionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      prUrl: prUrl ?? this.prUrl,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ContributionModel{id: $id, userId: $userId, projectId: $projectId, status: $status}';
  }
}

enum ContributionStatus { started, prOpen, merged, closed }
