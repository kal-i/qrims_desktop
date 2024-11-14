import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';
import '../model/notification.dart' as notif;
import '../model/notification.dart';

class NotificationRepository {
  const NotificationRepository(
    this._conn,
  );

  final Connection _conn;

  Future<String> _generateUniqueNotifId() async {
    while (true) {
      final notifId = generatedId('NOTIF');

      final result = await _conn.execute(
        Sql.named(
          '''SELECT COUNT(id) FROM Notifications WHERE id = @id;''',
        ),
        parameters: {
          'id': notifId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return notifId;
      }
    }
  }

  Future<String?> sendNotification({
    required String recipientId,
    required String senderId,
    required String message,
    required NotificationType type,
    required String referenceId,
  }) async {
    try {
      final notifId = await _generateUniqueNotifId();
      print('notif id: $notifId');
      print(recipientId);
      print(senderId);
      print(message);
      print(type);
      print(referenceId);
      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Notifications (id, recipient_id, sender_id, message, type, reference_id, created_at)
          VALUES (@id, @recipient_id, @sender_id, @message, @type, @reference_id, @created_at);
          ''',
        ),
        parameters: {
          'id': notifId,
          'recipient_id': recipientId,
          'sender_id': senderId,
          'message': message,
          'type': type.toString().split('.').last,
          'reference_id': referenceId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      print('notif send');

      return notifId;
    } catch (e) {
      throw Exception('Error sending notif: $e');
    }
  }

  Future<int> getNotificationsCount({
    required String recipientId,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
        SELECT COUNT(*) FROM Notifications
        WHERE recipient_id = @recipient_id;
        ''',
        ),
        parameters: {
          'recipient_id': recipientId,
        },
      );

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered issuances: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error counting notifications: $e');
      throw Exception('Failed to count notifications.');
    }
  }

  Future<List<notif.Notification>?> getNotifications({
    required int page,
    required int pageSize,
    required String recipientId,
  }) async {
    final offset = (page - 1) * pageSize;
    final notifications = <notif.Notification>[];

    final results = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Notifications
        WHERE recipient_id = @recipient_id
        ORDER BY created_at DESC
        LIMIT @page_size OFFSET @offset;
        ''',
      ),
      parameters: {
        'recipient_id': recipientId,
        'page_size': pageSize,
        'offset': offset,
      },
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        final sender = await UserRepository(_conn).getUserInformation(
          id: row[2] as String,
        );

        final notificationMap = {
          'notification_id': row[0],
          'recipient_id': row[1],
          'sender': sender is SupplyDepartmentEmployee
              ? sender.toJson()
              : sender is MobileUser
                  ? sender.toJson()
                  : null,
          'message': row[3],
          'type': row[4],
          'reference_id': row[5],
          'read': row[6],
          'created_at': row[7],
        };
        notifications.add(notif.Notification.fromJson(notificationMap));
      }
    }

    return notifications;
  }

  Future<bool?> markAsRead({
    required String notificationId,
    required bool read,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
      UPDATE Notifications
      SET read = @read
      WHERE id = @id,
      ''',
      ),
      parameters: {
        'id': notificationId,
        'read': read,
      },
    );

    return result.affectedRows == 1;
  }

  Future<List<notif.Notification>?> getNotificationTimelineTrail({
    required String referenceId, // refers to pr
  }) async {
    final notifications = <notif.Notification>[];

    final results = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Notifications
        WHERE reference_id = @reference_id
        ORDER BY created_at ASC;
        ''',
      ),
      parameters: {
        'reference_id': referenceId,
      },
    );

    print(results);

    if (results.isNotEmpty) {
      for (final row in results) {
        notifications.add(
          notif.Notification.fromJson({
            'notification_id': row[0],
            'recipient_id': row[1],
            'sender_id': row[2],
            'message': row[3],
            'type': row[4],
            'reference_id': row[5],
            'read': row[6],
            'created_at': row[7],
          }),
        );
      }
    }

    return notifications;
  }
}
