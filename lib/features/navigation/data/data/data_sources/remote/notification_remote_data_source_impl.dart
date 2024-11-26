import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/http_service.dart';

import '../../models/paginated_notification_result.dart';
import 'notification_remote_data_source.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<PaginatedNotificationResulModel> getNotifications({
    required int page,
    required int pageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      final response = await httpService.get(
        endpoint: notificationsEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        print(response.data);
        final notificationsJson =
            PaginatedNotificationResulModel.fromJson(response.data);

        print(notificationsJson);
        return notificationsJson;
      } else {
        throw const ServerException('Failed to load notifications.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> readNotification({
    required String notificationId,
    required bool read,
  }) async {
    try {
      final Map<String, dynamic> param = {
        'read': read,
      };

      final response = await httpService.patch(
        endpoint: '$notificationsEP/$notificationId',
        params: param,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
