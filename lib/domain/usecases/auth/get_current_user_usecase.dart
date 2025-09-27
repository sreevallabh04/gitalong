import 'package:injectable/injectable.dart';

import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

@injectable
/// Use case for getting the current authenticated user
class GetCurrentUserUseCase {
  /// Creates the use case
  GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  /// Gets the current user
  Future<UserEntity?> call() => _authRepository.getCurrentUser();
}
