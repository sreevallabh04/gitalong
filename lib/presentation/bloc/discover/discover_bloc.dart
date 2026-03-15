import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/services/backend_api_client.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/user/get_recommended_users_usecase.dart';
import '../../../../domain/usecases/swipe/swipe_user_usecase.dart';
import 'discover_event.dart';
import 'discover_state.dart';

@injectable
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetRecommendedUsersUseCase _getRecommendedUsersUseCase;
  final SwipeUserUseCase _swipeUserUseCase;
  final BackendApiClient _backendApiClient;

  List<UserEntity> _currentUsers = [];

  DiscoverBloc(
    this._getRecommendedUsersUseCase,
    this._swipeUserUseCase,
    this._backendApiClient,
  ) : super(DiscoverInitial()) {
    on<LoadRecommendationsEvent>(_onLoadRecommendations);
    on<SwipeUserEvent>(_onSwipeUser);
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendationsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    try {
      final users = await _getRecommendedUsersUseCase();
      _currentUsers = List.from(users);
      if (_currentUsers.isEmpty) {
        emit(DiscoverEmpty());
      } else {
        emit(DiscoverLoaded(users: _currentUsers));
      }
    } catch (e) {
      emit(DiscoverError(e.toString()));
    }
  }

  Future<void> _onSwipeUser(
    SwipeUserEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      // Remove the user from local list immediately for fast UI
      _currentUsers.removeWhere((u) => u.id == event.swipedUserId);

      // Tell backend about the swipe
      final match = await _swipeUserUseCase(
        swipedUserId: event.swipedUserId,
        action: event.action,
      );

      if (match != null) {
        // Notify backend so the other user gets "You matched with X!" in-app
        _backendApiClient.notifyNewMatch(
          match.id,
          match.user.id,
          match.user.name ?? match.user.username,
        );
        // Stop current flow to display match screen
        emit(DiscoverMatch(match: match, remainingUsers: List.from(_currentUsers)));
        // Re-emit loaded so UI can resume swiping behind the match dialog
        emit(DiscoverLoaded(users: List.from(_currentUsers)));
      } else {
        if (_currentUsers.isEmpty) {
          emit(DiscoverEmpty());
        } else {
          emit(DiscoverLoaded(users: List.from(_currentUsers)));
        }
      }
    } catch (e) {
      // Revert if error? For now just log/show error and continue
      emit(DiscoverError("Failed to record swipe: ${e.toString()}"));
      emit(DiscoverLoaded(users: List.from(_currentUsers)));
    }
  }
}
