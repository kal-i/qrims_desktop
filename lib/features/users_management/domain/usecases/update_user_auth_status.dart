import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/users_management_repository.dart';

class UpdateUserAuthStatus
    implements UseCase<bool, UpdateUserAuthStatusParams> {
  const UpdateUserAuthStatus({
    required this.usersManagementRepository,
  });

  final UsersManagementRepository usersManagementRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateUserAuthStatusParams params) async {
    return await usersManagementRepository.updateUserAuthenticationStatus(
      id: params.id,
      authStatus: params.authStatus,
    );
  }
}

class UpdateUserAuthStatusParams {
  const UpdateUserAuthStatusParams({
    required this.id,
    required this.authStatus,
  });

  final String id;
  final AuthStatus authStatus;
}
