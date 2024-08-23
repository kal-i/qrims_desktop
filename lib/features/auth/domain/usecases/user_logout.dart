import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/auth_repository.dart';

class UserLogout implements UseCase<void, String> {
  const UserLogout({
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Future<Either<Failure, void>> call(String param) async {
    return await authRepository.logout(token: param);
  }
}
