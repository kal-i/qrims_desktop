import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/user_activity.dart';
import '../repository/user_activity_repository.dart';

class GetUserActivities
    implements UseCase<List<UserActivityEntity>, GetUserActivitiesParams> {
  const GetUserActivities({
    required this.userActivityRepository,
  });

  final UserActivityRepository userActivityRepository;

  @override
  Future<Either<Failure, List<UserActivityEntity>>> call(
      GetUserActivitiesParams params) async {
    return await userActivityRepository.getUserActivities(
      userId: params.userId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetUserActivitiesParams {
  const GetUserActivitiesParams({
    required this.userId,
    required this.page,
    required this.pageSize,
  });

  final int userId;
  final int page;
  final int pageSize;
}
