import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/user_repository.dart';

class UserUpdateInfo implements UseCase<bool, UserUpdateInfoParams> {
  const UserUpdateInfo({
    required this.userRepository,
  });

  final UserRepository userRepository;

  @override
  Future<Either<Failure, bool>> call(UserUpdateInfoParams params) async {
    return await userRepository.updateUserInfo(
      id: params.id,
      profileImage: params.profileImage,
    );
  }
}

class UserUpdateInfoParams {
  const UserUpdateInfoParams({
    required this.id,
    this.profileImage,
  });

  final int id;
  final String? profileImage;
}
