import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_activity.dart';

abstract interface class UserActivityRepository {
  Future<Either<Failure, List<UserActivityEntity>>> getUserActivities({
    required int userId,
    required int page,
    required int pageSize,
  });
}
