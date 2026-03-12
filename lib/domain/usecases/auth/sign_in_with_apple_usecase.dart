import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

@injectable
class SignInWithAppleUseCase {
  final AuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  Future<UserEntity> call() {
    return _repository.signInWithApple();
  }
}
