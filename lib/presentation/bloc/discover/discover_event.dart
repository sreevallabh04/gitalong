import 'package:equatable/equatable.dart';
import '../../../../domain/entities/swipe_entity.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecommendationsEvent extends DiscoverEvent {}

class SwipeUserEvent extends DiscoverEvent {
  final String swipedUserId;
  final SwipeAction action;

  const SwipeUserEvent({
    required this.swipedUserId,
    required this.action,
  });

  @override
  List<Object?> get props => [swipedUserId, action];
}
