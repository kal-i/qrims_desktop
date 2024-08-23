import '../../models/user_activity.dart';

abstract interface class UserActivityRemoteDataSource {
  Future<List<UserActivityModel>> getUserActivities({
    required int userId,
    required int page,
    required int pageSize,
  });
}
