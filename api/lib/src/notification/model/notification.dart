import 'package:equatable/equatable.dart';

enum NotificationType {
  itemRegistration, // temp fn
  itemIssuance,
}

class Notification extends Equatable {
  const Notification({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.message,
    this.type,
    this.referenceId,
    required this.read,
    this.createdAt,
  });

  final int id;
  final int recipientId;
  final int senderId;
  final String message;
  final NotificationType? type;
  final int? referenceId;
  final bool read;
  final DateTime? createdAt;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['notification_id'] as int,
      recipientId: json['recipient_id'] as int,
      senderId: json['sender_id'] as int,
      message: json['message'] as String,
      type: json['type'] as NotificationType?,
      referenceId: json['reference_id'] as int?,
      read: json['read'] as bool,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        senderId,
        message,
        type,
        referenceId,
        read,
        createdAt,
      ];
}
