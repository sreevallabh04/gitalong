import 'package:equatable/equatable.dart';

/// User entity representing a developer profile
class UserEntity extends Equatable {
  /// Creates a user entity
  const UserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.website,
    this.company,
    this.skills = const [],
    this.languages = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.repositoriesCount = 0,
    this.contributionsCount = 0,
    required this.joinedAt,
    required this.lastActiveAt,
    this.isVerified = false,
    required this.preferences,
  });

  /// Unique identifier for the user
  final String id;

  /// Username of the user
  final String username;

  /// Display name of the user
  final String displayName;

  /// Email address of the user
  final String email;

  /// Avatar URL of the user
  final String? avatarUrl;

  /// Bio/description of the user
  final String? bio;

  /// Location of the user
  final String? location;

  /// Website URL of the user
  final String? website;

  /// Company the user works for
  final String? company;

  /// Skills of the user
  final List<String> skills;

  /// Programming languages the user knows
  final List<String> languages;

  /// Number of followers
  final int followersCount;

  /// Number of users being followed
  final int followingCount;

  /// Number of repositories
  final int repositoriesCount;

  /// Number of contributions
  final int contributionsCount;

  /// When the user joined
  final DateTime joinedAt;

  /// When the user was last active
  final DateTime lastActiveAt;

  /// Whether the user is verified
  final bool isVerified;

  /// User preferences and settings
  final UserPreferences preferences;

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    email,
    avatarUrl,
    bio,
    location,
    website,
    company,
    skills,
    languages,
    followersCount,
    followingCount,
    repositoriesCount,
    contributionsCount,
    joinedAt,
    lastActiveAt,
    isVerified,
    preferences,
  ];
}

/// User preferences and settings
class UserPreferences extends Equatable {
  /// Creates user preferences
  const UserPreferences({
    required this.showEmail,
    required this.showLocation,
    required this.showCompany,
    required this.allowDirectMessages,
    required this.allowProjectInvites,
    this.interestedTechnologies = const [],
    this.preferredCollaborationType = 'Any',
    this.maxDistanceKm = 100,
  });

  /// Whether to show email publicly
  final bool showEmail;

  /// Whether to show location publicly
  final bool showLocation;

  /// Whether to show company publicly
  final bool showCompany;

  /// Whether to allow direct messages
  final bool allowDirectMessages;

  /// Whether to allow project invites
  final bool allowProjectInvites;

  /// Technologies the user is interested in
  final List<String> interestedTechnologies;

  /// Preferred type of collaboration
  final String preferredCollaborationType;

  /// Maximum distance for matches in kilometers
  final int maxDistanceKm;

  @override
  List<Object?> get props => [
    showEmail,
    showLocation,
    showCompany,
    allowDirectMessages,
    allowProjectInvites,
    interestedTechnologies,
    preferredCollaborationType,
    maxDistanceKm,
  ];
}
