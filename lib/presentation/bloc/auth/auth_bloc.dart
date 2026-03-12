import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_github_usecase.dart';
import '../../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInWithGitHubUseCase _signInWithGitHubUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;

  AuthBloc(
    this._getCurrentUserUseCase,
    this._signInWithGitHubUseCase,
    this._signInWithGoogleUseCase,
    this._signOutUseCase,
    this._deleteAccountUseCase,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithGitHubEvent>(_onSignInWithGitHub);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
    on<DeleteAccountEvent>(_onDeleteAccount);
    
    // Automatically intercept browser sign in callbacks from deep links
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _getCurrentUserUseCase.call();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGitHub(
      SignInWithGitHubEvent event, Emitter<AuthState> emit) async {
    // The browser launch is external. We don't block or emit AuthAuthenticated here.
    // The stream listener for onAuthStateChange handles exactly when we are signed in.
    try {
      await _signInWithGitHubUseCase.call();
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase.call();
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _signInWithGoogleUseCase.call();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _deleteAccountUseCase.call();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to delete account: $e'));
      // fallback to unauthenticated or just error? Let's assume if it fails we stay authenticated
      final user = await _getCurrentUserUseCase.call();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }
}
