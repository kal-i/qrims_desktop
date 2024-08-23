import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserResetPassword implements UseCase<bool, UserResetPasswordParams> {
  const UserResetPassword({
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, bool>> call(UserResetPasswordParams params) async {
    return await authRepository.resetPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserResetPasswordParams {
  const UserResetPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
