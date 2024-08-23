import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

// UseCase<Type, Params>
class UserLogin implements UseCase<UserEntity, UserLoginParams> {
  const UserLogin({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UserLoginParams params) async {
    // return await authRepository.login(
    //   email: params.email,
    //   password: params.password,
    // );

    return await authRepository.bearerLogin(
      email: params.email,
      password: params.password,
    );
  }
}

class UserLoginParams {
  const UserLoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
