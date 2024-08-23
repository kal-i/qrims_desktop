import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserVerifyOtp implements UseCase<bool, UserVerifyOtpParams> {
  const UserVerifyOtp({
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, bool>> call(UserVerifyOtpParams params) async {
    return await authRepository.verifyEmailOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

class UserVerifyOtpParams {
  const UserVerifyOtpParams({
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;
}
