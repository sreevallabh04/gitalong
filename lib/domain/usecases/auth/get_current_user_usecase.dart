import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Get current user use case
@injectable
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  const GetCurrentUserUseCase(this._authRepository);

  /// Execute the use case
  Future<UserEntity?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
