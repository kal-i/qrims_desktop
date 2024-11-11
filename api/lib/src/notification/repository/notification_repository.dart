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

  Future<List<notif.Notification>?> getNotifications({
    required String recipientId,
  }) async {
    final notifications = <notif.Notification>[];

    final results = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Notifications
        WHERE recipient_id = @recipient_id
        ORDER BY created_at DESC;
        ''',
      ),
      parameters: {
        'recipient_id': recipientId,
      },
    );

    print(results);

    if (results.isNotEmpty) {
      for (final row in results) {
        final notificationMap = {
          'notification_id': row[0],
          'recipient_id': row[1],
          'sender_id': row[2],
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
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
      UPDATE Notifications
      SET read = TRUE
      WHERE id = @id,
      ''',
      ),
      parameters: {
        'id': notificationId,
      },
    );

    return result.affectedRows == 1;
  }
}
