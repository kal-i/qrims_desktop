import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';

abstract interface class UserRepository {

  Future<Either<Failure, bool>> updateUserInfo({
    required int id,
    String? profileImage,
  });
}
