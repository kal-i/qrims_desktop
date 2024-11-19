import 'package:equatable/equatable.dart';

import '../../user/models/user.dart';

/// when pr is registered, we will send a notif to user
///
enum NotificationType {
  prCreated, // When a purchase request is created
  prApproved, // When a purchase request is approved
  prFollowUp,
  prPartiallyFulfilled, // When part of the requested items are issued
  prFulfilled, // When the PR is fully fulfilled
  prCancelled, // When a PR is cancelled
  issuanceCreated, // When a new issuance is created for a PR
  issuanceReceived, // When an issuance is received by the requesting officer id
  generalAlert,
}

class Notification extends Equatable {
  const Notification({
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
  final User sender;
  final String message;
  final NotificationType? type;
  final String? referenceId;
  final bool read;
  final DateTime? createdAt;

  factory Notification.fromJson(Map<String, dynamic> json) {
    final senderMap = json['sender'] as Map<String, dynamic>;
    User sender;

    if (senderMap.containsKey('supp_dept_emp_id')) {
      sender = SupplyDepartmentEmployee.fromJson(senderMap);
    } else {
      final mobileUserMap = {
        'user_id': senderMap['user_id'],
        'name': senderMap['name'],
        'email': senderMap['email'],
        'password': senderMap['password'],
        'created_at': senderMap['created_at'],
        'updated_at': senderMap['updated_at'],
        'auth_status': senderMap['auth_status'],
        'is_archived': senderMap['is_archived'],
        'otp': senderMap['otp'],
        'otp_expiry': senderMap['otp_expiry'],
        'profile_image': senderMap['profile_image'],
        'mobile_user_id': senderMap['mobile_user_id'],
        'officer_id': senderMap['officer']['id'],
        'officer_user_id': senderMap['officer']['user_id'],
        'officer_name': senderMap['officer']['name'],
        'position_id': senderMap['officer']['position_id'],
        'office_name': senderMap['officer']['office_name'],
        'position_name': senderMap['officer']['position_name'],
        'officer_is_archived': senderMap['officer']['is_archived'],
        'admin_approval_status': senderMap['admin_approval_status'],
      };
      print('mobile sender: $mobileUserMap');
      sender = MobileUser.fromJson(mobileUserMap);
    }

    final type = NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'] as String,
    );

    return Notification(
      id: json['notification_id'] as String,
      recipientId: json['recipient_id'] as String,
      sender: sender,
      message: json['message'] as String,
      type: type,
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
      'sender': sender,
      'message': message,
      'type': type.toString().split('.').last,
      'reference_id': referenceId,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        recipientId,
        sender,
        message,
        type,
        referenceId,
        read,
        createdAt,
      ];
}
