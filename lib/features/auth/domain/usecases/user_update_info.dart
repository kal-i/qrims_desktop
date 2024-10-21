import '../../../../core/entities/user.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserUpdateInfo implements UseCase<UserEntity, UserUpdateInfoParams> {
  const UserUpdateInfo({
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, UserEntity>> call(UserUpdateInfoParams params) async {
    return await authRepository.updateUserInformation(
      id: params.id,
      profileImage: params.profileImage,
      password: params.password,
    );
  }
}

class UserUpdateInfoParams {
  const UserUpdateInfoParams({
    required this.id,
    this.profileImage,
    this.password,
  });

  final String id;
  final String? profileImage;
  final String? password;
}
