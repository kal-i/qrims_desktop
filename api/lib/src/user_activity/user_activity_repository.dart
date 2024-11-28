import 'package:api/src/user_activity/user_activity.dart';
import 'package:postgres/postgres.dart';

class UserActivityRepository {
  const UserActivityRepository(this._conn);

  final Connection _conn;

  /// Logs user act to db and broadcast it to ws clients
  Future<UserActivity> logUserActivity({
    required String userId,
    required String description,
    required Action actionType,
    String? targetId,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        'user_id': userId,
        'description': description,
        'action_type': actionType.toString().split('.').last,
        'created_at': DateTime.now().toIso8601String(),
      };

      String baseQuery = '''
        INSERT INTO UserActivities (user_id, description, action_type, created_at
      ''';

      if (targetId != null) {
        baseQuery += ', target_id';
        parameters['target_id'] = targetId;
      }

      baseQuery +=
          ') VALUES (@user_id, @description, @action_type, @created_at';

      if (targetId != null) {
        baseQuery += ', @target_id';
      }

      baseQuery += ') RETURNING user_act_id';

      final result = await _conn.execute(
        Sql.named(
          baseQuery,
        ),
        parameters: parameters,
      );

      final userActId = result.first[0] as int;

      final userActivity = UserActivity(
        id: userActId,
        userId: userId,
        description: description,
        actionType: actionType,
        createdAt: DateTime.now(),
      );

      return userActivity;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<UserActivity>> getUserActivities({
    required int id,
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final userActivityList = <UserActivity>[];

      final results = await _conn.execute(
        Sql.named(
          '''
          SELECT
            user_act_id,
            user_id,
            description,
            action_type,
            target_id,
            created_at
          FROM 
            UserActivities
          WHERE 
            user_id = @user_id
          ORDER BY
            created_at DESC
          LIMIT
            @page_size OFFSET @offset;
          ''',
        ),
        parameters: {
          'user_id': id,
          'page_size': pageSize,
          'offset': offset,
        },
      );

      for (final row in results) {
        final userActivityMap = {
          'user_act_id': row[0] as int,
          'user_id': row[1] as int,
          'description': row[2] as String,
          'action_type': row[3] as String,
          'target_id': row[4] != null ? row[4] as int : null,
          'created_at':
              row[5] is DateTime ? row[5] : DateTime.parse(row[5] as String),
        };

        userActivityList.add(UserActivity.fromJson(userActivityMap));
      }

      return userActivityList;
    } catch (e) {
      throw Exception('Failed to fetch user activities: ${e.toString()}');
    }
  }
}
