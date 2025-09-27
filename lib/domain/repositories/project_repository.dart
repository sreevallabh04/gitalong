import '../entities/project_entity.dart';

/// Repository for project-related operations
abstract class ProjectRepository {
  /// Get project by ID
  Future<ProjectEntity?> getProjectById(String projectId);

  /// Get projects by user ID
  Future<List<ProjectEntity>> getProjectsByUser(
    String userId, {
    int limit = 20,
  });

  /// Get trending projects
  Future<List<ProjectEntity>> getTrendingProjects({int limit = 20});

  /// Get recommended projects for user
  Future<List<ProjectEntity>> getRecommendedProjects(
    String userId, {
    int limit = 20,
  });

  /// Search projects by query
  Future<List<ProjectEntity>> searchProjects(String query, {int limit = 20});

  /// Get projects by technology
  Future<List<ProjectEntity>> getProjectsByTechnology(
    String technology, {
    int limit = 20,
  });

  /// Get projects by language
  Future<List<ProjectEntity>> getProjectsByLanguage(
    String language, {
    int limit = 20,
  });

  /// Star a project
  Future<void> starProject(String projectId);

  /// Unstar a project
  Future<void> unstarProject(String projectId);

  /// Check if project is starred
  Future<bool> isProjectStarred(String projectId);

  /// Fork a project
  Future<ProjectEntity> forkProject(String projectId);

  /// Get project contributors
  Future<List<ProjectContributor>> getProjectContributors(String projectId);

  /// Get project statistics
  Future<ProjectStats> getProjectStats(String projectId);

  /// Get project commits
  Future<List<ProjectCommit>> getProjectCommits(
    String projectId, {
    int limit = 20,
  });

  /// Get project issues
  Future<List<ProjectIssue>> getProjectIssues(
    String projectId, {
    int limit = 20,
  });

  /// Get project pull requests
  Future<List<ProjectPullRequest>> getProjectPullRequests(
    String projectId, {
    int limit = 20,
  });

  /// Stream of project updates
  Stream<ProjectEntity> getProjectUpdates(String projectId);
}

/// Represents a project commit
class ProjectCommit {
  /// Unique identifier for the commit
  final String id;

  /// Commit message
  final String message;

  /// Author of the commit
  final String author;

  /// Avatar URL of the author
  final String? authorAvatarUrl;

  /// Date of the commit
  final DateTime date;

  /// Hash of the commit
  final String hash;

  /// Creates a project commit
  const ProjectCommit({
    required this.id,
    required this.message,
    required this.author,
    required this.date,
    required this.hash,
    this.authorAvatarUrl,
  });
}

/// Represents a project issue
class ProjectIssue {
  /// Unique identifier for the issue
  final String id;

  /// Title of the issue
  final String title;

  /// Body/description of the issue
  final String body;

  /// Current state of the issue
  final String state;

  /// Author of the issue
  final String author;

  /// Avatar URL of the author
  final String? authorAvatarUrl;

  /// When the issue was created
  final DateTime createdAt;

  /// When the issue was closed
  final DateTime? closedAt;

  /// Labels associated with the issue
  final List<String> labels;

  /// Creates a project issue
  const ProjectIssue({
    required this.id,
    required this.title,
    required this.body,
    required this.state,
    required this.author,
    required this.createdAt,
    required this.labels,
    this.authorAvatarUrl,
    this.closedAt,
  });
}

/// Represents a project pull request
class ProjectPullRequest {
  /// Unique identifier for the pull request
  final String id;

  /// Title of the pull request
  final String title;

  /// Body/description of the pull request
  final String body;

  /// Current state of the pull request
  final String state;

  /// Author of the pull request
  final String author;

  /// Avatar URL of the author
  final String? authorAvatarUrl;

  /// When the pull request was created
  final DateTime createdAt;

  /// When the pull request was merged
  final DateTime? mergedAt;

  /// Base branch of the pull request
  final String? baseBranch;

  /// Head branch of the pull request
  final String? headBranch;

  /// Creates a project pull request
  const ProjectPullRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.state,
    required this.author,
    required this.createdAt,
    this.authorAvatarUrl,
    this.mergedAt,
    this.baseBranch,
    this.headBranch,
  });
}
