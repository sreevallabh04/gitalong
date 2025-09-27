import 'package:equatable/equatable.dart';

/// Project entity representing a GitHub project
class ProjectEntity extends Equatable {
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

  /// Technologies used in the project
  final List<String> technologies;

  /// Programming languages used
  final List<String> languages;

  /// Current status of the project
  final ProjectStatus status;

  /// Type of project (web, mobile, desktop, etc.)
  final ProjectType type;

  /// Number of stars
  final int starsCount;

  /// Number of forks
  final int forksCount;

  /// Number of watchers
  final int watchersCount;

  /// Number of open issues
  final int issuesCount;

  /// Number of open pull requests
  final int pullRequestsCount;

  /// When the project was created
  final DateTime createdAt;

  /// When the project was last updated
  final DateTime updatedAt;

  /// When the project was last committed to
  final DateTime? lastCommitAt;

  /// Whether the project is public
  final bool isPublic;

  /// Whether the project is archived
  final bool isArchived;

  /// Whether the project is a fork
  final bool isFork;

  /// List of project contributors
  final List<ProjectContributor> contributors;

  /// Project topics/tags
  final List<String> topics;

  /// Project statistics
  final ProjectStats stats;

  /// Creates a project entity
  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
    this.readme,
    required this.ownerId,
    required this.ownerUsername,
    this.ownerAvatarUrl,
    required this.repositoryUrl,
    this.websiteUrl,
    this.demoUrl,
    required this.technologies,
    required this.languages,
    required this.status,
    required this.type,
    required this.starsCount,
    required this.forksCount,
    required this.watchersCount,
    required this.issuesCount,
    required this.pullRequestsCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastCommitAt,
    required this.isPublic,
    required this.isArchived,
    required this.isFork,
    required this.contributors,
    required this.topics,
    required this.stats,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    readme,
    ownerId,
    ownerUsername,
    ownerAvatarUrl,
    repositoryUrl,
    websiteUrl,
    demoUrl,
    technologies,
    languages,
    status,
    type,
    starsCount,
    forksCount,
    watchersCount,
    issuesCount,
    pullRequestsCount,
    createdAt,
    updatedAt,
    lastCommitAt,
    isPublic,
    isArchived,
    isFork,
    contributors,
    topics,
    stats,
  ];
}

/// Project contributor entity
class ProjectContributor extends Equatable {
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

  /// Creates a project contributor
  const ProjectContributor({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.contributions,
    required this.role,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl, contributions, role];
}

/// Project statistics entity
class ProjectStats extends Equatable {
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

  /// Commit activity over time
  final List<CommitActivity> commitActivity;

  /// Creates project statistics
  const ProjectStats({
    required this.totalCommits,
    required this.totalLinesAdded,
    required this.totalLinesDeleted,
    required this.activityScore,
    required this.recentCommits,
    required this.commitActivity,
  });

  @override
  List<Object?> get props => [
    totalCommits,
    totalLinesAdded,
    totalLinesDeleted,
    activityScore,
    recentCommits,
    commitActivity,
  ];
}

/// Commit activity entity
class CommitActivity extends Equatable {
  /// Date of the commit activity
  final DateTime date;

  /// Number of commits on this date
  final int commits;

  /// Creates commit activity
  const CommitActivity({required this.date, required this.commits});

  @override
  List<Object?> get props => [date, commits];
}

enum ProjectStatus { active, maintenance, archived, deprecated }

enum ProjectType { web, mobile, desktop, library, framework, tool, game, other }
