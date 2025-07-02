/// GitHub user model that integrates with real GitHub API data
/// This makes our profile cards incredibly rich and developer-focused
class GitHubUser {
  const GitHubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    this.name,
    this.bio,
    this.location,
    this.company,
    this.blog,
    this.email,
    required this.publicRepos,
    required this.followers,
    required this.following,
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.topLanguages = const [],
    this.totalStars = 0,
    this.totalCommits = 0,
    this.latestCommitMessage,
    this.contributionsThisYear = 0,
    this.contributionStreak = 0,
  });

  final int id;
  final String login;
  final String avatarUrl;
  final String? name;
  final String? bio;
  final String? location;
  final String? company;
  final String? blog;
  final String? email;
  final int publicRepos;
  final int followers;
  final int following;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final List<String> topLanguages;
  final int totalStars;
  final int totalCommits;
  final String? latestCommitMessage;
  final int contributionsThisYear;
  final int contributionStreak;

  /// Profile URL on GitHub
  String get profileUrl => 'https://github.com/$login';

  /// HTML URL for GitHub profile (alias for profileUrl)
  String get htmlUrl => profileUrl;

  /// Display name (prefers name over login)
  String get displayName => name ?? login;

  /// Member since text
  String get memberSince {
    if (createdAt == null) return 'GitHub member';
    final year = createdAt!.year;
    return 'GitHub member since $year';
  }

  /// Contribution level based on yearly activity
  ContributionLevel get contributionLevel {
    if (contributionsThisYear >= 1000) return ContributionLevel.legendary;
    if (contributionsThisYear >= 500) return ContributionLevel.active;
    if (contributionsThisYear >= 100) return ContributionLevel.moderate;
    if (contributionsThisYear >= 10) return ContributionLevel.beginner;
    return ContributionLevel.inactive;
  }

  /// Creates GitHubUser from GitHub API response
  factory GitHubUser.fromGitHubApi(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] ?? 0,
      login: json['login'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      name: json['name'],
      bio: json['bio'],
      location: json['location'],
      company: json['company'],
      blog: json['blog'],
      email: json['email'],
      publicRepos: json['public_repos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Creates enriched GitHubUser with additional computed data
  factory GitHubUser.fromEnrichedData({
    required Map<String, dynamic> basicData,
    List<String>? languages,
    int? stars,
    int? commits,
    String? latestCommit,
    int? contributions,
    int? streak,
  }) {
    final basic = GitHubUser.fromGitHubApi(basicData);

    return GitHubUser(
      id: basic.id,
      login: basic.login,
      avatarUrl: basic.avatarUrl,
      name: basic.name,
      bio: basic.bio,
      location: basic.location,
      company: basic.company,
      blog: basic.blog,
      email: basic.email,
      publicRepos: basic.publicRepos,
      followers: basic.followers,
      following: basic.following,
      createdAt: basic.createdAt,
      updatedAt: basic.updatedAt,
      topLanguages: languages ?? [],
      totalStars: stars ?? 0,
      totalCommits: commits ?? 0,
      latestCommitMessage: latestCommit,
      contributionsThisYear: contributions ?? 0,
      contributionStreak: streak ?? 0,
      isVerified: basic.followers > 1000 || basic.publicRepos > 50,
    );
  }

  /// Creates sample GitHubUser for development/demo
  factory GitHubUser.sample({
    String? login,
    String? name,
    String? bio,
  }) {
    final sampleLogin = login ?? 'octocat';
    return GitHubUser(
      id: 583231,
      login: sampleLogin,
      avatarUrl: 'https://github.com/identicons/$sampleLogin.png',
      name: name ?? 'The Octocat',
      bio: bio ??
          'Building the future of version control, one commit at a time.',
      location: 'San Francisco, CA',
      company: '@github',
      publicRepos: 42,
      followers: 4500,
      following: 9,
      createdAt: DateTime(2011, 1, 25),
      updatedAt: DateTime.now(),
      isVerified: true,
      topLanguages: ['JavaScript', 'TypeScript', 'Python', 'Go', 'Rust'],
      totalStars: 1250,
      totalCommits: 3420,
      latestCommitMessage: 'feat: implement dark mode for all components',
      contributionsThisYear: 847,
      contributionStreak: 23,
    );
  }

  /// Factory constructor for creating sample user from ML recommendation
  factory GitHubUser.sampleFromRecommendation(dynamic recommendation) {
    final sampleUsers = [
      const GitHubUser(
        login: 'alex_dev',
        id: 12345,
        avatarUrl: 'https://github.com/alex_dev.png',
        name: 'Alex Chen',
        bio:
            'Full-stack developer passionate about React and Node.js. Love contributing to open source projects.',
        publicRepos: 25,
        followers: 150,
        following: 89,
        location: 'San Francisco, CA',
        topLanguages: ['JavaScript', 'TypeScript', 'React', 'Node.js'],
        totalStars: 420,
        totalCommits: 1250,
        contributionsThisYear: 420,
        contributionStreak: 15,
      ),
      const GitHubUser(
        login: 'sarah_flutter',
        id: 67890,
        avatarUrl: 'https://github.com/sarah_flutter.png',
        name: 'Sarah Kim',
        bio:
            'Mobile app developer specializing in Flutter. Looking for exciting projects to collaborate on.',
        publicRepos: 18,
        followers: 89,
        following: 67,
        location: 'Seattle, WA',
        topLanguages: ['Dart', 'Flutter', 'Firebase', 'Python'],
        totalStars: 320,
        totalCommits: 890,
        contributionsThisYear: 320,
        contributionStreak: 12,
      ),
    ];

    // Return a random sample user for demo purposes
    return sampleUsers[DateTime.now().millisecond % sampleUsers.length];
  }

  /// Generates multiple sample users for demos
  static List<GitHubUser> generateSampleUsers() {
    return [
      GitHubUser.sample(
        login: 'torvalds',
        name: 'Linus Torvalds',
        bio: 'Creator of Linux and Git. Finnish-American software engineer.',
      ),
      GitHubUser.sample(
        login: 'gaearon',
        name: 'Dan Abramov',
        bio: 'Co-creator of Redux. Works on React at Meta.',
      ),
      GitHubUser.sample(
        login: 'tj',
        name: 'TJ Holowaychuk',
        bio: 'Creator of Express.js and many other Node.js modules.',
      ),
      GitHubUser.sample(
        login: 'sindresorhus',
        name: 'Sindre Sorhus',
        bio: 'Full-time open-sourcerer. Creator of AVA, Chalk, XO.',
      ),
      GitHubUser.sample(
        login: 'addyosmani',
        name: 'Addy Osmani',
        bio:
            'Engineering Manager at Google working on Chrome & web performance.',
      ),
    ];
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'name': name,
      'bio': bio,
      'location': location,
      'company': company,
      'blog': blog,
      'email': email,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified,
      'top_languages': topLanguages,
      'total_stars': totalStars,
      'total_commits': totalCommits,
      'latest_commit_message': latestCommitMessage,
      'contributions_this_year': contributionsThisYear,
      'contribution_streak': contributionStreak,
    };
  }

  /// JSON deserialization
  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] ?? 0,
      login: json['login'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      name: json['name'],
      bio: json['bio'],
      location: json['location'],
      company: json['company'],
      blog: json['blog'],
      email: json['email'],
      publicRepos: json['public_repos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      isVerified: json['is_verified'] ?? false,
      topLanguages: (json['top_languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      totalStars: json['total_stars'] ?? 0,
      totalCommits: json['total_commits'] ?? 0,
      latestCommitMessage: json['latest_commit_message'],
      contributionsThisYear: json['contributions_this_year'] ?? 0,
      contributionStreak: json['contribution_streak'] ?? 0,
    );
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'GitHubUser(login: $login, name: $name, repos: $publicRepos, followers: $followers)';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitHubUser && other.id == id && other.login == login;
  }

  @override
  int get hashCode => Object.hash(id, login);

  /// Creates a copy with updated fields
  GitHubUser copyWith({
    int? id,
    String? login,
    String? avatarUrl,
    String? name,
    String? bio,
    String? location,
    String? company,
    String? blog,
    String? email,
    int? publicRepos,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    List<String>? topLanguages,
    int? totalStars,
    int? totalCommits,
    String? latestCommitMessage,
    int? contributionsThisYear,
    int? contributionStreak,
  }) {
    return GitHubUser(
      id: id ?? this.id,
      login: login ?? this.login,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      company: company ?? this.company,
      blog: blog ?? this.blog,
      email: email ?? this.email,
      publicRepos: publicRepos ?? this.publicRepos,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      topLanguages: topLanguages ?? this.topLanguages,
      totalStars: totalStars ?? this.totalStars,
      totalCommits: totalCommits ?? this.totalCommits,
      latestCommitMessage: latestCommitMessage ?? this.latestCommitMessage,
      contributionsThisYear:
          contributionsThisYear ?? this.contributionsThisYear,
      contributionStreak: contributionStreak ?? this.contributionStreak,
    );
  }
}

/// Contribution activity levels
enum ContributionLevel {
  inactive('Inactive', 'Less than 10 contributions this year'),
  beginner('Beginner', '10-100 contributions this year'),
  moderate('Moderate', '100-500 contributions this year'),
  active('Active', '500-1000 contributions this year'),
  legendary('Legendary', '1000+ contributions this year');

  const ContributionLevel(this.label, this.description);

  final String label;
  final String description;
}
