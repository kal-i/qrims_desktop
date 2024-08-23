import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserSendOtp implements UseCase<bool, String> {
  const UserSendOtp({
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, bool>> call(String emailParam) async {
    return await authRepository.sendEmailOtp(
      email: emailParam,
    );
  }
}
