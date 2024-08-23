import 'package:postgres/postgres.dart';

import '../model/notification.dart' as notif;

class NotificationRepository {
  const NotificationRepository(
    this._conn,
  );

  final Connection _conn;

  Future<notif.Notification> sendNotification({
    required Map<String, dynamic> params,
  }) async {
    final recipientId = params['recipient_id'] as int;
    final senderId = params['sender_id'] as int;
    final message = params['message'] as String;
    final type = params['type'] as notif.NotificationType?;
    final referenceId = params['reference_id'] as int?;

    print(recipientId);
    print(senderId);


    final result = await _conn.execute(
      Sql.named(
        '''
      INSERT INTO Notifications (recipient_id, sender_id, message, type, reference_id)
      VALUES (@recipient_id, @sender_id, @message, @type, @reference_id)
      RETURNING id;
      ''',
      ),
      parameters: {
        'recipient_id': recipientId,
        'sender_id': senderId,
        'message': message,
        'type': type.toString().split('.').last,
        'reference_id': referenceId,
      },
    );

    final notificationId = result.first[0] as int;

    return notif.Notification(
      id: notificationId,
      recipientId: recipientId,
      senderId: senderId,
      message: message,
      type: type,
      referenceId: referenceId,
      read: false,
      //createdAt: DateTime.now(),
    );
  }

  Future<List<notif.Notification>?> getNotifications({
    required int recipientId,
  }) async {
    final notifications = <notif.Notification>[];

    final results = await _conn.execute(
      Sql.named(
        '''
        SELECT * Notifications
        WHERE recipient_id = @recipient_id
        ORDER BY created_at DESC;
        ''',
      ),
      parameters: {
        'recipient_id': recipientId,
      },
    );

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

  Future<void> markAsRead({
    required int notificationId,
  }) async {
    await _conn.execute(
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
  }
}
