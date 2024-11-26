import '../../../../../core/entities/user.dart';
import '../../../../../core/enums/notification_type.dart';

class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.sender,
    required this.message,
    this.type,
    this.referenceId,
    required this.read,
    this.createdAt,
  });

  final String id;
  final String recipientId;
  final UserEntity sender;
  final String message;
  final NotificationType? type;
  final String? referenceId;
  final bool read;
  final DateTime? createdAt;
}