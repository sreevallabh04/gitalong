class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String repoUrl;
  final List<String> skillsRequired;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatus status;
  final String? imageUrl;
  final int? stars;
  final String? language;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.repoUrl,
    this.skillsRequired = const [],
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.status = ProjectStatus.active,
    this.imageUrl,
    this.stars,
    this.language,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      repoUrl: json['repo_url'] as String,
      skillsRequired: List<String>.from(json['skills_required'] ?? []),
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: ProjectStatus.values.byName(json['status'] ?? 'active'),
      imageUrl: json['image_url'] as String?,
      stars: json['stars'] as int?,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'repo_url': repoUrl,
      'skills_required': skillsRequired,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
      'image_url': imageUrl,
      'stars': stars,
      'language': language,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? repoUrl,
    List<String>? skillsRequired,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectStatus? status,
    String? imageUrl,
    int? stars,
    String? language,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      repoUrl: repoUrl ?? this.repoUrl,
      skillsRequired: skillsRequired ?? this.skillsRequired,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      stars: stars ?? this.stars,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectModel{id: $id, title: $title, ownerId: $ownerId}';
  }
}

enum ProjectStatus { active, paused, completed }
