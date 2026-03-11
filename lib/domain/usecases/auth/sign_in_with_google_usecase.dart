import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Google
@injectable
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<UserEntity> call() {
    return _repository.signInWithGoogle();
  }
}
