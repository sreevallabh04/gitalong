import 'package:equatable/equatable.dart';

/// Repository entity
class RepositoryEntity extends Equatable {
  final String id;
  final String name;
  final String fullName;
  final String? description;
  final String owner;
  final String ownerAvatarUrl;
  final String? language;
  final int stars;
  final int forks;
  final int watchers;
  final int openIssues;
  final bool isPrivate;
  final bool isFork;
  final String? homepageUrl;
  final String htmlUrl;
  final List<String> topics;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RepositoryEntity({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.owner,
    required this.ownerAvatarUrl,
    this.language,
    this.stars = 0,
    this.forks = 0,
    this.watchers = 0,
    this.openIssues = 0,
    this.isPrivate = false,
    this.isFork = false,
    this.homepageUrl,
    required this.htmlUrl,
    this.topics = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    fullName,
    description,
    owner,
    ownerAvatarUrl,
    language,
    stars,
    forks,
    watchers,
    openIssues,
    isPrivate,
    isFork,
    homepageUrl,
    htmlUrl,
    topics,
    createdAt,
    updatedAt,
  ];
}
