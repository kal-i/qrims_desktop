import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_activity.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/repository/user_activity_repository.dart';
import '../data_sources/remote/user_activity_remote_data_source.dart';

class UserActivityRepositoryImpl implements UserActivityRepository {
  const UserActivityRepositoryImpl({
    required this.userActivityRemoteDataSource,
  });

  final UserActivityRemoteDataSource userActivityRemoteDataSource;

  @override
  Future<Either<Failure, List<UserActivityEntity>>> getUserActivities({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final userActModelList =
          await userActivityRemoteDataSource.getUserActivities(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );

      print(userActModelList);
      return right(userActModelList);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
