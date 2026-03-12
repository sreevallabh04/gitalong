import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// User data model - uses snake_case for Postgres column compatibility
@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.name,
    super.bio,
    super.avatarUrl,
    super.location,
    super.company,
    super.websiteUrl,
    super.githubUrl,
    super.followers,
    super.following,
    super.publicRepos,
    super.languages,
    super.interests,
    required super.createdAt,
    super.lastActiveAt,
    @JsonKey(includeToJson: false) super.matchScore,
    @JsonKey(includeToJson: false) super.scoreBreakdown,
  });

  /// From JSON (Supabase row)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// To JSON (insert / update to Supabase)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// From entity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        username: entity.username,
        email: entity.email,
        name: entity.name,
        bio: entity.bio,
        avatarUrl: entity.avatarUrl,
        location: entity.location,
        company: entity.company,
        websiteUrl: entity.websiteUrl,
        githubUrl: entity.githubUrl,
        followers: entity.followers,
        following: entity.following,
        publicRepos: entity.publicRepos,
        languages: entity.languages,
        interests: entity.interests,
        createdAt: entity.createdAt,
        lastActiveAt: entity.lastActiveAt,
        matchScore: entity.matchScore,
        scoreBreakdown: entity.scoreBreakdown,
      );

  /// To entity
  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
        location: location,
        company: company,
        websiteUrl: websiteUrl,
        githubUrl: githubUrl,
        followers: followers,
        following: following,
        publicRepos: publicRepos,
        languages: languages,
        interests: interests,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt,
        matchScore: matchScore,
        scoreBreakdown: scoreBreakdown,
      );
}
