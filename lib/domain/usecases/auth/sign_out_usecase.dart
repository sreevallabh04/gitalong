import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

/// Sign out use case
@injectable
class SignOutUseCase {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  /// Execute the use case
  Future<void> call() async {
    return await _authRepository.signOut();
  }
}
