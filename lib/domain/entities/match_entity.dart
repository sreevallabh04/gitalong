import 'package:equatable/equatable.dart';

/// Match entity representing a successful match between users
class MatchEntity extends Equatable {
  /// Unique identifier for the match
  final String id;

  /// ID of the first user in the match
  final String userId1;

  /// ID of the second user in the match
  final String userId2;

  /// Type of match (user-to-user, user-to-project)
  final MatchType type;

  /// Current status of the match
  final MatchStatus status;

  /// When the match was created
  final DateTime matchedAt;

  /// When the users last interacted
  final DateTime? lastInteractionAt;

  /// ID of the chat between matched users
  final String? chatId;

  /// Reason why the users matched
  final MatchReason reason;

  /// Creates a match entity
  const MatchEntity({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.type,
    required this.status,
    required this.matchedAt,
    this.lastInteractionAt,
    this.chatId,
    required this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    userId1,
    userId2,
    type,
    status,
    matchedAt,
    lastInteractionAt,
    chatId,
    reason,
  ];
}

/// Swipe action entity representing user swipe actions
class SwipeActionEntity extends Equatable {
  /// Unique identifier for the swipe action
  final String id;

  /// ID of the user who performed the swipe
  final String swiperId;

  /// ID of the target being swiped on
  final String targetId;

  /// Type of swipe (like, pass, super_like)
  final SwipeType type;

  /// Type of target (user, project)
  final SwipeTarget targetType;

  /// When the swipe was performed
  final DateTime swipedAt;

  /// Optional reason for the swipe
  final String? reason;

  /// Creates a swipe action entity
  const SwipeActionEntity({
    required this.id,
    required this.swiperId,
    required this.targetId,
    required this.type,
    required this.targetType,
    required this.swipedAt,
    this.reason,
  });

  @override
  List<Object?> get props => [
    id,
    swiperId,
    targetId,
    type,
    targetType,
    swipedAt,
    reason,
  ];
}

/// Match reason entity explaining why users matched
class MatchReason extends Equatable {
  /// Technologies both users have in common
  final List<String> commonTechnologies;

  /// Interests both users share
  final List<String> commonInterests;

  /// Compatibility score between users
  final double compatibilityScore;

  /// Mutual connection between users
  final String? mutualConnection;

  /// Project both users are interested in
  final String? sharedProject;

  /// Creates a match reason
  const MatchReason({
    required this.commonTechnologies,
    required this.commonInterests,
    required this.compatibilityScore,
    this.mutualConnection,
    this.sharedProject,
  });

  @override
  List<Object?> get props => [
    commonTechnologies,
    commonInterests,
    compatibilityScore,
    mutualConnection,
    sharedProject,
  ];
}

enum MatchType { user, project }

enum MatchStatus { active, archived, blocked }

enum SwipeType { like, pass, superLike }

enum SwipeTarget { user, project }
