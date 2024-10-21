
import '../entities/user.dart';
import 'mobile_user.dart';
import 'supply_department_employee.dart';

abstract class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.password,
    required super.createdAt,
    super.updatedAt,
    super.authStatus,
    super.isArchived,
    super.otp,
    super.otpExpiry,
    super.profileImage,
  });

  /// This worked because of the concept of polymorphism, in which it recognizes
  /// both supp dept emp and mobile user classes as a subtype of user model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('user model: $json');
    if (json['role'] != null) {
      return SupplyDepartmentEmployeeModel.fromJson(json);
    } else {
      return MobileUserModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}