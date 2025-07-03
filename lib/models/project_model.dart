import 'package:cloud_firestore/cloud_firestore.dart';

/// Project status enum
enum ProjectStatus {
  active,
  completed,
  paused,
  archived,
}

/// Project model for maintainers to upload and contributors to discover
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
  final String? language;
  final int? stars;
  final int? forks;
  final String? license;
  final List<String> tags;
  final bool isPublic;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.repoUrl,
    required this.skillsRequired,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.status = ProjectStatus.active,
    this.imageUrl,
    this.language,
    this.stars,
    this.forks,
    this.license,
    this.tags = const [],
    this.isPublic = true,
  });

  /// Create ProjectModel from JSON with safe parsing
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse skills with fallback
      List<String> skillsList = [];
      if (json['skills_required'] != null) {
        if (json['skills_required'] is List) {
          skillsList = (json['skills_required'] as List)
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } else if (json['skillsRequired'] != null) {
        if (json['skillsRequired'] is List) {
          skillsList = (json['skillsRequired'] as List)
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }

      // Parse tags with fallback
      List<String> tagsList = [];
      if (json['tags'] != null && json['tags'] is List) {
        tagsList = (json['tags'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }

      // Parse status with fallback
      ProjectStatus projectStatus = ProjectStatus.active;
      if (json['status'] != null) {
        try {
          projectStatus = ProjectStatus.values.firstWhere(
            (e) => e.name == json['status'].toString(),
            orElse: () => ProjectStatus.active,
          );
        } catch (e) {
          projectStatus = ProjectStatus.active;
        }
      }

      // Parse timestamps with multiple field name support
      DateTime createdAt = DateTime.now();
      DateTime updatedAt = DateTime.now();

      // Handle created_at / createdAt
      if (json['created_at'] != null) {
        if (json['created_at'] is Timestamp) {
          createdAt = (json['created_at'] as Timestamp).toDate();
        } else if (json['created_at'] is String) {
          createdAt = DateTime.tryParse(json['created_at']) ?? DateTime.now();
        }
      } else if (json['createdAt'] != null) {
        if (json['createdAt'] is Timestamp) {
          createdAt = (json['createdAt'] as Timestamp).toDate();
        } else if (json['createdAt'] is String) {
          createdAt = DateTime.tryParse(json['createdAt']) ?? DateTime.now();
        }
      }

      // Handle updated_at / updatedAt
      if (json['updated_at'] != null) {
        if (json['updated_at'] is Timestamp) {
          updatedAt = (json['updated_at'] as Timestamp).toDate();
        } else if (json['updated_at'] is String) {
          updatedAt = DateTime.tryParse(json['updated_at']) ?? DateTime.now();
        }
      } else if (json['updatedAt'] != null) {
        if (json['updatedAt'] is Timestamp) {
          updatedAt = (json['updatedAt'] as Timestamp).toDate();
        } else if (json['updatedAt'] is String) {
          updatedAt = DateTime.tryParse(json['updatedAt']) ?? DateTime.now();
        }
      }

      return ProjectModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Project',
        description: json['description']?.toString() ?? '',
        repoUrl: json['repo_url']?.toString() ?? json['repoUrl']?.toString() ?? '',
        skillsRequired: skillsList,
        ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
        createdAt: createdAt,
        updatedAt: updatedAt,
        status: projectStatus,
        imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
        language: json['language']?.toString(),
        stars: json['stars'] is int ? json['stars'] as int : null,
        forks: json['forks'] is int ? json['forks'] as int : null,
        license: json['license']?.toString(),
        tags: tagsList,
        isPublic: json['is_public'] is bool 
            ? json['is_public'] as bool 
            : json['isPublic'] is bool 
                ? json['isPublic'] as bool 
                : true,
      );
    } catch (e) {
      // Return a minimal valid model on parsing errors
      return ProjectModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Untitled Project',
        description: json['description']?.toString() ?? '',
        repoUrl: json['repo_url']?.toString() ?? json['repoUrl']?.toString() ?? '',
        skillsRequired: const [],
        ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Convert ProjectModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'repo_url': repoUrl,
      'skills_required': skillsRequired,
      'owner_id': ownerId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'status': status.name,
      'image_url': imageUrl,
      'language': language,
      'stars': stars,
      'forks': forks,
      'license': license,
      'tags': tags,
      'is_public': isPublic,
    };
  }

  /// Create a copy of this project with updated fields
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
    String? language,
    int? stars,
    int? forks,
    String? license,
    List<String>? tags,
    bool? isPublic,
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
      language: language ?? this.language,
      stars: stars ?? this.stars,
      forks: forks ?? this.forks,
      license: license ?? this.license,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title, status: $status)';
  }
}
