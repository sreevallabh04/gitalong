import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

@JsonSerializable()
/// Data model for project entity
class ProjectModel {
  /// Creates a project model
  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerUsername,
    required this.repositoryUrl,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
    this.readme,
    this.ownerAvatarUrl,
    this.websiteUrl,
    this.demoUrl,
    this.technologies = const [],
    this.languages = const [],
    this.starsCount = 0,
    this.forksCount = 0,
    this.watchersCount = 0,
    this.issuesCount = 0,
    this.pullRequestsCount = 0,
    this.lastCommitAt,
    this.isPublic = true,
    this.isArchived = false,
    this.isFork = false,
    this.contributors = const [],
    this.topics = const [],
  });

  /// Creates a project model from JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  /// Converts the project model to JSON
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  /// Unique identifier for the project
  final String id;

  /// Name of the project
  final String name;

  /// Description of the project
  final String description;

  /// README content of the project
  final String? readme;

  /// ID of the project owner
  final String ownerId;

  /// Username of the project owner
  final String ownerUsername;

  /// Avatar URL of the project owner
  final String? ownerAvatarUrl;

  /// URL of the repository
  final String repositoryUrl;

  /// Website URL of the project
  final String? websiteUrl;

  /// Demo URL of the project
  final String? demoUrl;
  @JsonKey(defaultValue: <String>[])
  /// Technologies used in the project
  final List<String> technologies;
  @JsonKey(defaultValue: <String>[])
  /// Programming languages used
  final List<String> languages;

  /// Current status of the project
  final String status;

  /// Type of project
  final String type;
  @JsonKey(defaultValue: 0)
  /// Number of stars
  final int starsCount;
  @JsonKey(defaultValue: 0)
  /// Number of forks
  final int forksCount;
  @JsonKey(defaultValue: 0)
  /// Number of watchers
  final int watchersCount;
  @JsonKey(defaultValue: 0)
  /// Number of open issues
  final int issuesCount;
  @JsonKey(defaultValue: 0)
  /// Number of open pull requests
  final int pullRequestsCount;

  /// When the project was created
  final DateTime createdAt;

  /// When the project was last updated
  final DateTime updatedAt;

  /// When the project was last committed to
  final DateTime? lastCommitAt;
  @JsonKey(defaultValue: true)
  /// Whether the project is public
  final bool isPublic;
  @JsonKey(defaultValue: false)
  /// Whether the project is archived
  final bool isArchived;
  @JsonKey(defaultValue: false)
  /// Whether the project is a fork
  final bool isFork;
  @JsonKey(defaultValue: <ProjectContributorModel>[])
  /// List of project contributors
  final List<ProjectContributorModel> contributors;
  @JsonKey(defaultValue: <String>[])
  /// Project topics/tags
  final List<String> topics;

  /// Project statistics
  final ProjectStatsModel stats;
}

@JsonSerializable()
/// Data model for project contributor
class ProjectContributorModel {
  /// Creates a project contributor model
  const ProjectContributorModel({
    required this.id,
    required this.username,
    required this.contributions,
    this.avatarUrl,
    this.role = 'Contributor',
  });

  /// Creates a project contributor model from JSON
  factory ProjectContributorModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectContributorModelFromJson(json);

  /// Converts the project contributor model to JSON
  Map<String, dynamic> toJson() => _$ProjectContributorModelToJson(this);

  /// Unique identifier for the contributor
  final String id;

  /// Username of the contributor
  final String username;

  /// Avatar URL of the contributor
  final String? avatarUrl;

  /// Number of contributions made
  final int contributions;

  /// Role of the contributor in the project
  final String role;
}

@JsonSerializable()
/// Data model for project statistics
class ProjectStatsModel {
  /// Creates project statistics model
  const ProjectStatsModel({
    required this.totalCommits,
    required this.totalLinesAdded,
    required this.totalLinesDeleted,
    required this.activityScore,
    required this.recentCommits,
    this.commitActivity = const [],
  });

  /// Creates a project statistics model from JSON
  factory ProjectStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectStatsModelFromJson(json);

  /// Converts the project statistics model to JSON
  Map<String, dynamic> toJson() => _$ProjectStatsModelToJson(this);

  /// Total number of commits
  final int totalCommits;

  /// Total lines of code added
  final int totalLinesAdded;

  /// Total lines of code deleted
  final int totalLinesDeleted;

  /// Activity score of the project
  final double activityScore;

  /// Number of recent commits
  final int recentCommits;
  @JsonKey(defaultValue: <CommitActivityModel>[])
  /// Commit activity over time
  final List<CommitActivityModel> commitActivity;
}

@JsonSerializable()
/// Data model for commit activity
class CommitActivityModel {
  /// Creates commit activity model
  const CommitActivityModel({required this.date, required this.commits});

  /// Creates a commit activity model from JSON
  factory CommitActivityModel.fromJson(Map<String, dynamic> json) =>
      _$CommitActivityModelFromJson(json);

  /// Converts the commit activity model to JSON
  Map<String, dynamic> toJson() => _$CommitActivityModelToJson(this);

  /// Date of the commit activity
  final DateTime date;

  /// Number of commits on this date
  final int commits;
}

/// Extension methods for ProjectModel
extension ProjectModelX on ProjectModel {
  /// Converts the project model to entity
  ProjectEntity toEntity() => ProjectEntity(
    id: id,
    name: name,
    description: description,
    readme: readme,
    ownerId: ownerId,
    ownerUsername: ownerUsername,
    ownerAvatarUrl: ownerAvatarUrl,
    repositoryUrl: repositoryUrl,
    websiteUrl: websiteUrl,
    demoUrl: demoUrl,
    technologies: technologies,
    languages: languages,
    status: ProjectStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ProjectStatus.active,
    ),
    type: ProjectType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ProjectType.other,
    ),
    starsCount: starsCount,
    forksCount: forksCount,
    watchersCount: watchersCount,
    issuesCount: issuesCount,
    pullRequestsCount: pullRequestsCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastCommitAt: lastCommitAt,
    isPublic: isPublic,
    isArchived: isArchived,
    isFork: isFork,
    contributors: contributors.map((c) => c.toEntity()).toList(),
    topics: topics,
    stats: stats.toEntity(),
  );
}

/// Extension methods for ProjectEntity
extension ProjectEntityX on ProjectEntity {
  /// Converts the project entity to model
  ProjectModel toModel() => ProjectModel(
    id: id,
    name: name,
    description: description,
    readme: readme,
    ownerId: ownerId,
    ownerUsername: ownerUsername,
    ownerAvatarUrl: ownerAvatarUrl,
    repositoryUrl: repositoryUrl,
    websiteUrl: websiteUrl,
    demoUrl: demoUrl,
    technologies: technologies,
    languages: languages,
    status: status.name,
    type: type.name,
    starsCount: starsCount,
    forksCount: forksCount,
    watchersCount: watchersCount,
    issuesCount: issuesCount,
    pullRequestsCount: pullRequestsCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastCommitAt: lastCommitAt,
    isPublic: isPublic,
    isArchived: isArchived,
    isFork: isFork,
    contributors: contributors.map((c) => c.toModel()).toList(),
    topics: topics,
    stats: stats.toModel(),
  );
}

/// Extension methods for ProjectContributorModel
extension ProjectContributorModelX on ProjectContributorModel {
  /// Converts the project contributor model to entity
  ProjectContributor toEntity() => ProjectContributor(
    id: id,
    username: username,
    avatarUrl: avatarUrl,
    contributions: contributions,
    role: role,
  );
}

/// Extension methods for ProjectContributor
extension ProjectContributorX on ProjectContributor {
  /// Converts the project contributor entity to model
  ProjectContributorModel toModel() => ProjectContributorModel(
    id: id,
    username: username,
    avatarUrl: avatarUrl,
    contributions: contributions,
    role: role,
  );
}

/// Extension methods for ProjectStatsModel
extension ProjectStatsModelX on ProjectStatsModel {
  /// Converts the project statistics model to entity
  ProjectStats toEntity() => ProjectStats(
    totalCommits: totalCommits,
    totalLinesAdded: totalLinesAdded,
    totalLinesDeleted: totalLinesDeleted,
    activityScore: activityScore,
    recentCommits: recentCommits,
    commitActivity: commitActivity.map((c) => c.toEntity()).toList(),
  );
}

/// Extension methods for ProjectStats
extension ProjectStatsX on ProjectStats {
  /// Converts the project statistics entity to model
  ProjectStatsModel toModel() => ProjectStatsModel(
    totalCommits: totalCommits,
    totalLinesAdded: totalLinesAdded,
    totalLinesDeleted: totalLinesDeleted,
    activityScore: activityScore,
    recentCommits: recentCommits,
    commitActivity: commitActivity.map((c) => c.toModel()).toList(),
  );
}

/// Extension methods for CommitActivityModel
extension CommitActivityModelX on CommitActivityModel {
  /// Converts the commit activity model to entity
  CommitActivity toEntity() => CommitActivity(date: date, commits: commits);
}

/// Extension methods for CommitActivity
extension CommitActivityX on CommitActivity {
  /// Converts the commit activity entity to model
  CommitActivityModel toModel() =>
      CommitActivityModel(date: date, commits: commits);
}
