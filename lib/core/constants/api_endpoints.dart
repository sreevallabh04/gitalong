/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // GitHub API
  static const String user = '/user';
  static const String userRepos = '/user/repos';
  static const String searchUsers = '/search/users';
  static const String searchRepos = '/search/repositories';
  static const String trending = '/trending';

  // User endpoints
  static String userProfile(String username) => '/users/$username';
  static String userReposList(String username) => '/users/$username/repos';
  static String userFollowers(String username) => '/users/$username/followers';
  static String userFollowing(String username) => '/users/$username/following';

  // Repository endpoints
  static String repoDetails(String owner, String repo) => '/repos/$owner/$repo';
  static String repoStargazers(String owner, String repo) =>
      '/repos/$owner/$repo/stargazers';
  static String repoContributors(String owner, String repo) =>
      '/repos/$owner/$repo/contributors';
  static String repoLanguages(String owner, String repo) =>
      '/repos/$owner/$repo/languages';
}
