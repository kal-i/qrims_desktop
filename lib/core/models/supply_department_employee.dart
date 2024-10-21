import 'dart:convert';

import '../entities/supply_department_employee.dart';
import '../enums/auth_status.dart';
import '../enums/role.dart';
import 'user.dart';

class SupplyDepartmentEmployeeModel extends SupplyDepartmentEmployeeEntity
    implements UserModel {
  const SupplyDepartmentEmployeeModel({
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
    required super.employeeId,
    required super.role,
  });

  factory SupplyDepartmentEmployeeModel.fromJson(Map<String, dynamic> json) {
    final authStatusString = json['auth_status'] as String;
    final roleString = json['role'] as String;

    print('AuthStatus string from JSON: $authStatusString');
    print('Role string from JSON: $roleString');

    // remove the prefix value in enums if present
    final authStatusValue = authStatusString.startsWith('AuthStatus.')
        ? authStatusString.substring(10)
        : authStatusString;
    final roleValue =
        roleString.startsWith('Role.') ? roleString.substring(5) : roleString;

    print('processed AuthStatus String: $authStatusValue');
    print('processed role string: $roleValue');

    // extract the last part of the role then compare to the retrieved role String
    final authStatus = AuthStatus.values.firstWhere(
      (e) => e.toString().split('.').last == authStatusValue,
      orElse: () => AuthStatus.unauthenticated,
    );
    final role = Role.values.firstWhere(
      (e) => e.toString().split('.').last == roleValue,
      orElse: () => Role.supplyCustodian,
    );

    print('AuthStatus after conversion: $authStatus');
    print('Role after conversion: $role');

    return SupplyDepartmentEmployeeModel(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
      updatedAt: json['updated_at'] != null
          ? json['updated_at'] is String
              ? DateTime.parse(json['updated_at'] as String)
              : json['updated_at'] as DateTime
          : null,
      authStatus: authStatus,
      isArchived: json['is_archived'],
      otp: json['otp'],
      otpExpiry: json['otp_expiry'] != null
          ? json['otp_expiry'] is String
              ? DateTime.parse(json['otp_expiry'] as String)
              : json['otp_expiry'] as DateTime
          : null,
      profileImage: json['profile_image'] != null
          ? json['profile_image'] as String
          : null,
      employeeId: json['supp_dept_emp_id'],
      role: role,
    );
  }

  factory SupplyDepartmentEmployeeModel.fromEntity(
      SupplyDepartmentEmployeeEntity supplyDepartmentEntity) {
    return SupplyDepartmentEmployeeModel(
      id: supplyDepartmentEntity.id,
      name: supplyDepartmentEntity.name,
      email: supplyDepartmentEntity.email,
      password: supplyDepartmentEntity.password,
      createdAt: supplyDepartmentEntity.createdAt,
      employeeId: supplyDepartmentEntity.employeeId,
      role: supplyDepartmentEntity.role,
      profileImage: supplyDepartmentEntity.profileImage,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'password': password,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'auth_status': authStatus,
      'is_archived': isArchived,
      'otp': otp,
      'otp_expiry': otpExpiry,
      'profile_image':
          profileImage,
      'employee_id': employeeId,
      'role': role.toString().split('.').last,
    };
  }
}
