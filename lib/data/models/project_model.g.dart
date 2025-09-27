// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  readme: json['readme'] as String?,
  ownerId: json['ownerId'] as String,
  ownerUsername: json['ownerUsername'] as String,
  ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
  repositoryUrl: json['repositoryUrl'] as String,
  websiteUrl: json['websiteUrl'] as String?,
  demoUrl: json['demoUrl'] as String?,
  technologies:
      (json['technologies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  status: json['status'] as String,
  type: json['type'] as String,
  starsCount: (json['starsCount'] as num?)?.toInt() ?? 0,
  forksCount: (json['forksCount'] as num?)?.toInt() ?? 0,
  watchersCount: (json['watchersCount'] as num?)?.toInt() ?? 0,
  issuesCount: (json['issuesCount'] as num?)?.toInt() ?? 0,
  pullRequestsCount: (json['pullRequestsCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  lastCommitAt:
      json['lastCommitAt'] == null
          ? null
          : DateTime.parse(json['lastCommitAt'] as String),
  isPublic: json['isPublic'] as bool? ?? true,
  isArchived: json['isArchived'] as bool? ?? false,
  isFork: json['isFork'] as bool? ?? false,
  contributors:
      (json['contributors'] as List<dynamic>?)
          ?.map(
            (e) => ProjectContributorModel.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  topics:
      (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  stats: ProjectStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      if (instance.readme case final value?) 'readme': value,
      'ownerId': instance.ownerId,
      'ownerUsername': instance.ownerUsername,
      if (instance.ownerAvatarUrl case final value?) 'ownerAvatarUrl': value,
      'repositoryUrl': instance.repositoryUrl,
      if (instance.websiteUrl case final value?) 'websiteUrl': value,
      if (instance.demoUrl case final value?) 'demoUrl': value,
      'technologies': instance.technologies,
      'languages': instance.languages,
      'status': instance.status,
      'type': instance.type,
      'starsCount': instance.starsCount,
      'forksCount': instance.forksCount,
      'watchersCount': instance.watchersCount,
      'issuesCount': instance.issuesCount,
      'pullRequestsCount': instance.pullRequestsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      if (instance.lastCommitAt?.toIso8601String() case final value?)
        'lastCommitAt': value,
      'isPublic': instance.isPublic,
      'isArchived': instance.isArchived,
      'isFork': instance.isFork,
      'contributors': instance.contributors.map((e) => e.toJson()).toList(),
      'topics': instance.topics,
      'stats': instance.stats.toJson(),
    };

ProjectContributorModel _$ProjectContributorModelFromJson(
  Map<String, dynamic> json,
) => ProjectContributorModel(
  id: json['id'] as String,
  username: json['username'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  contributions: (json['contributions'] as num?)?.toInt() ?? 0,
  role: json['role'] as String? ?? 'contributor',
);

Map<String, dynamic> _$ProjectContributorModelToJson(
  ProjectContributorModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  if (instance.avatarUrl case final value?) 'avatarUrl': value,
  'contributions': instance.contributions,
  'role': instance.role,
};

ProjectStatsModel _$ProjectStatsModelFromJson(Map<String, dynamic> json) =>
    ProjectStatsModel(
      totalCommits: (json['totalCommits'] as num?)?.toInt() ?? 0,
      totalLinesAdded: (json['totalLinesAdded'] as num?)?.toInt() ?? 0,
      totalLinesDeleted: (json['totalLinesDeleted'] as num?)?.toInt() ?? 0,
      activityScore: (json['activityScore'] as num?)?.toDouble() ?? 0.0,
      recentCommits: (json['recentCommits'] as num?)?.toInt() ?? 0,
      commitActivity:
          (json['commitActivity'] as List<dynamic>?)
              ?.map(
                (e) => CommitActivityModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProjectStatsModelToJson(ProjectStatsModel instance) =>
    <String, dynamic>{
      'totalCommits': instance.totalCommits,
      'totalLinesAdded': instance.totalLinesAdded,
      'totalLinesDeleted': instance.totalLinesDeleted,
      'activityScore': instance.activityScore,
      'recentCommits': instance.recentCommits,
      'commitActivity': instance.commitActivity.map((e) => e.toJson()).toList(),
    };

CommitActivityModel _$CommitActivityModelFromJson(Map<String, dynamic> json) =>
    CommitActivityModel(
      date: DateTime.parse(json['date'] as String),
      commits: (json['commits'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CommitActivityModelToJson(
  CommitActivityModel instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'commits': instance.commits,
};
