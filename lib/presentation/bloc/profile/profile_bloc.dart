import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../../domain/usecases/match/get_matches_usecase.dart';
import '../../../../domain/usecases/user/update_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetMatchesUseCase _getMatchesUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  ProfileBloc(
    this._getCurrentUserUseCase,
    this._getMatchesUseCase,
    this._updateUserProfileUseCase,
  ) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<RefreshStatsEvent>(_onRefreshStats);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user == null) {
        emit(const ProfileError('User not found. Please log in again.'));
        return;
      }

      final matches = await _getMatchesUseCase(limit: 100);
      final matchCount = matches.length;
      final chatCount = matches.where((m) => m.lastMessage != null).length;

      emit(ProfileLoaded(
        user: user,
        matchCount: matchCount,
        chatCount: chatCount,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onRefreshStats(
    RefreshStatsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadProfileEvent());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final prevState = state;
    emit(ProfileUpdating());
    try {
      final updatedUser = await _updateUserProfileUseCase(event.updatedUser);

      int matchCount = 0;
      int chatCount = 0;
      if (prevState is ProfileLoaded) {
        matchCount = prevState.matchCount;
        chatCount = prevState.chatCount;
      }

      emit(ProfileLoaded(
        user: updatedUser,
        matchCount: matchCount,
        chatCount: chatCount,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
