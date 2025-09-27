import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

@injectable
/// Use case for signing in with GitHub
class SignInWithGitHubUseCase {
  /// Creates the use case
  SignInWithGitHubUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Signs in with GitHub
  Future<UserEntity> call() => _authRepository.signInWithGitHub();
}
