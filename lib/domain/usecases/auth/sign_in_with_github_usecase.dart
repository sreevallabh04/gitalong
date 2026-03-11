import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Sign in with GitHub use case
@injectable
class SignInWithGitHubUseCase {
  final AuthRepository _authRepository;

  const SignInWithGitHubUseCase(this._authRepository);

  /// Execute the use case
  Future<UserEntity> call() async {
    return await _authRepository.signInWithGitHub();
  }
}
