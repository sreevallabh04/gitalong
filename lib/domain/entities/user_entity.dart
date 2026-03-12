import 'package:equatable/equatable.dart';

/// User entity
class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? name;
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final String? company;
  final String? websiteUrl;
  final String? githubUrl;
  final int followers;
  final int following;
  final int publicRepos;
  final List<String> languages;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final double? matchScore;
  final Map<String, dynamic>? scoreBreakdown;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.bio,
    this.avatarUrl,
    this.location,
    this.company,
    this.websiteUrl,
    this.githubUrl,
    this.followers = 0,
    this.following = 0,
    this.publicRepos = 0,
    this.languages = const [],
    this.interests = const [],
    required this.createdAt,
    this.lastActiveAt,
    this.matchScore,
    this.scoreBreakdown,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    name,
    bio,
    avatarUrl,
    location,
    company,
    websiteUrl,
    githubUrl,
    followers,
    following,
    publicRepos,
    languages,
    interests,
    createdAt,
    lastActiveAt,
    matchScore,
    scoreBreakdown,
  ];

  /// Copy with method
  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? bio,
    String? avatarUrl,
    String? location,
    String? company,
    String? websiteUrl,
    String? githubUrl,
    int? followers,
    int? following,
    int? publicRepos,
    List<String>? languages,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    double? matchScore,
    Map<String, dynamic>? scoreBreakdown,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      company: company ?? this.company,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      publicRepos: publicRepos ?? this.publicRepos,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      matchScore: matchScore ?? this.matchScore,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
    );
  }
}
