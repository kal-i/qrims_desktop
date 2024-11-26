import '../../../../../core/enums/notification_type.dart';
import '../../../../../core/models/mobile_user.dart';
import '../../../../../core/models/supply_department_employee.dart';
import '../../../../../core/models/user.dart';
import '../../../domain/domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    required super.sender,
    required super.message,
    super.type,
    super.referenceId,
    required super.read,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final senderMap = json['sender'] as Map<String, dynamic>;
    UserModel sender;

    if (senderMap.containsKey('supp_dept_emp_id')) {
      //print('supp dept sender: $senderMap');
      sender = SupplyDepartmentEmployeeModel.fromJson(senderMap);
    } else {
      print(senderMap);
      print('mobile sender: ${senderMap['officer']}');
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
        'officer': {
          'id': senderMap['officer']['id'],
          'user_id': senderMap['officer']['user_id'],
          'name': senderMap['officer']['name'],
          'position_id': senderMap['officer']['position_id'],
          'office_name': senderMap['officer']['office_name'],
          'position_name': senderMap['officer']['position_name'],
          'is_archived': senderMap['officer']['is_archived'],
        },
        'admin_approval_status': senderMap['admin_approval_status'],
      };

      sender = MobileUserModel.fromJson(mobileUserMap);
      print('after mobile conversion: ------- $sender');
    }

    print('received json: $json');
    final type = NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'] as String,
    );

    return NotificationModel(
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
}
