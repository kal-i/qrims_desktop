import 'package:equatable/equatable.dart';

import '../../user/models/user.dart';

/// when pr is registered, we will send a notif to user
///
enum NotificationType {
  prCreated,           // When a purchase request is created
  prApproved,          // When a purchase request is approved
  prPartiallyFulfilled, // When part of the requested items are issued
  prFulfilled,         // When the PR is fully fulfilled
  prCancelled,         // When a PR is cancelled
  issuanceCreated,     // When a new issuance is created for a PR
  generalAlert,
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

  final String id;
  final String recipientId;
  final String senderId;
  final String message;
  final NotificationType? type;
  final String? referenceId;
  final bool read;
  final DateTime? createdAt;

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['notification_id'] as String,
      recipientId: json['recipient_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      type: json['type'] as NotificationType?,
      referenceId: json['reference_id'] as String?,
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
