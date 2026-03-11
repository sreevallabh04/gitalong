import 'package:equatable/equatable.dart';

/// Swipe entity
class SwipeEntity extends Equatable {
  final String id;
  final String swiperId;
  final String swipedUserId;
  final SwipeAction action;
  final DateTime swipedAt;

  const SwipeEntity({
    required this.id,
    required this.swiperId,
    required this.swipedUserId,
    required this.action,
    required this.swipedAt,
  });

  @override
  List<Object?> get props => [id, swiperId, swipedUserId, action, swipedAt];
}

/// Swipe action enum
enum SwipeAction { like, dislike, superLike }
