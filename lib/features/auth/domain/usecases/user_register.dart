import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/user.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

// class AuthenticateUseCase {
//   const AuthenticateUseCase(this._authRepository);
//
//   final AuthRepository _authRepository;
//
//   Future<DataState<UserEntity>> login({
//     required String email,
//     required String password,
//   }) {
//     return _authRepository.login(
//       email: email,
//       password: password,
//     );
//   }
//
//   Future<void> logout() async {
//     return _authRepository.logout();
//   }
// }

/// Since UseCase only accepts a single type, we cannot pass the name, email, etc.
/// which is why we created a class
class UserRegister implements UseCase<UserEntity, UserRegisterParams> {
  const UserRegister({required this.authRepository});

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UserRegisterParams params) async {
    print('auc: ${params.role}');

    return await authRepository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class UserRegisterParams {
  const UserRegisterParams({
    required this.name,
    required this.email,
    required this.password,
    this.role,
  });

  final String name;
  final String email;
  final String password;
  final Role? role;
}
