import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
/// Data model for user entity
class UserModel {
  /// Creates a user model
  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.preferences,
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
    this.isVerified = false,
  });

  /// Creates a user model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts the user model to JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

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
  @JsonKey(defaultValue: <String>[])
  /// Skills of the user
  final List<String> skills;
  @JsonKey(defaultValue: <String>[])
  /// Programming languages the user knows
  final List<String> languages;
  @JsonKey(defaultValue: 0)
  /// Number of followers
  final int followersCount;
  @JsonKey(defaultValue: 0)
  /// Number of users being followed
  final int followingCount;
  @JsonKey(defaultValue: 0)
  /// Number of repositories
  final int repositoriesCount;
  @JsonKey(defaultValue: 0)
  /// Number of contributions
  final int contributionsCount;

  /// When the user joined
  final DateTime joinedAt;

  /// When the user was last active
  final DateTime lastActiveAt;
  @JsonKey(defaultValue: false)
  /// Whether the user is verified
  final bool isVerified;

  /// User preferences and settings
  final UserPreferencesModel preferences;
}

@JsonSerializable()
/// Data model for user preferences
class UserPreferencesModel {
  /// Creates a user preferences model
  const UserPreferencesModel({
    this.showEmail = true,
    this.showLocation = true,
    this.showCompany = true,
    this.allowDirectMessages = true,
    this.allowProjectInvites = true,
    this.interestedTechnologies = const [],
    this.preferredCollaborationType = 'collaboration',
    this.maxDistanceKm = 50,
  });

  /// Creates a user preferences model from JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  /// Converts the user preferences model to JSON
  Map<String, dynamic> toJson() => _$UserPreferencesModelToJson(this);

  @JsonKey(defaultValue: true)
  /// Whether to show email publicly
  final bool showEmail;
  @JsonKey(defaultValue: true)
  /// Whether to show location publicly
  final bool showLocation;
  @JsonKey(defaultValue: true)
  /// Whether to show company publicly
  final bool showCompany;
  @JsonKey(defaultValue: true)
  /// Whether to allow direct messages
  final bool allowDirectMessages;
  @JsonKey(defaultValue: true)
  /// Whether to allow project invites
  final bool allowProjectInvites;
  @JsonKey(defaultValue: <String>[])
  /// Technologies the user is interested in
  final List<String> interestedTechnologies;
  @JsonKey(defaultValue: 'collaboration')
  /// Preferred type of collaboration
  final String preferredCollaborationType;
  @JsonKey(defaultValue: 50)
  /// Maximum distance for matches in kilometers
  final int maxDistanceKm;
}

/// Extension methods for UserModel
extension UserModelX on UserModel {
  /// Converts the user model to entity
  UserEntity toEntity() => UserEntity(
    id: id,
    username: username,
    displayName: displayName,
    email: email,
    avatarUrl: avatarUrl,
    bio: bio,
    location: location,
    website: website,
    company: company,
    skills: skills,
    languages: languages,
    followersCount: followersCount,
    followingCount: followingCount,
    repositoriesCount: repositoriesCount,
    contributionsCount: contributionsCount,
    joinedAt: joinedAt,
    lastActiveAt: lastActiveAt,
    isVerified: isVerified,
    preferences: preferences.toEntity(),
  );
}

/// Extension methods for UserEntity
extension UserEntityX on UserEntity {
  /// Converts the user entity to model
  UserModel toModel() => UserModel(
    id: id,
    username: username,
    displayName: displayName,
    email: email,
    avatarUrl: avatarUrl,
    bio: bio,
    location: location,
    website: website,
    company: company,
    skills: skills,
    languages: languages,
    followersCount: followersCount,
    followingCount: followingCount,
    repositoriesCount: repositoriesCount,
    contributionsCount: contributionsCount,
    joinedAt: joinedAt,
    lastActiveAt: lastActiveAt,
    isVerified: isVerified,
    preferences: preferences.toModel(),
  );
}

/// Extension methods for UserPreferencesModel
extension UserPreferencesModelX on UserPreferencesModel {
  /// Converts the user preferences model to entity
  UserPreferences toEntity() => UserPreferences(
    showEmail: showEmail,
    showLocation: showLocation,
    showCompany: showCompany,
    allowDirectMessages: allowDirectMessages,
    allowProjectInvites: allowProjectInvites,
    interestedTechnologies: interestedTechnologies,
    preferredCollaborationType: preferredCollaborationType,
    maxDistanceKm: maxDistanceKm,
  );
}

/// Extension methods for UserPreferences
extension UserPreferencesX on UserPreferences {
  /// Converts the user preferences entity to model
  UserPreferencesModel toModel() => UserPreferencesModel(
    showEmail: showEmail,
    showLocation: showLocation,
    showCompany: showCompany,
    allowDirectMessages: allowDirectMessages,
    allowProjectInvites: allowProjectInvites,
    interestedTechnologies: interestedTechnologies,
    preferredCollaborationType: preferredCollaborationType,
    maxDistanceKm: maxDistanceKm,
  );
}
