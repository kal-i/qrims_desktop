import 'dart:convert';
import 'dart:typed_data';

import 'package:api/src/organization_management/models/officer.dart';
import 'package:equatable/equatable.dart';

// TODO: Modify the schemas - DONE
// TODO: Update the data models - DONE
// TODO: Update the user repository - (repo the one interacting with the db) - DONE

// TODO: change id to alphanumeric
// TODO: implement a function for updating is_archive

/// How the authentication process works:
/// since the desktop is only limited to the supply department, it won't be necessary to have admin approval
/// as for the mobile, admin approval is necessary to avoid unauthorized access to the sys

/// Represents the state of user's authentication process to access the system.
enum AuthStatus {
  unauthenticated,

  /// user not completed the necessary steps to be considered auth ['email ver']
  authenticated,

  /// user verified the identity
  revoked,

  /// user access has been revoked
}

/// Base User Abstract Class
abstract class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    this.updatedAt,
    this.authStatus = AuthStatus.unauthenticated,
    this.isArchived = false,
    this.otp,
    this.otpExpiry,
    this.profileImage,
  });

  final String id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final AuthStatus authStatus;
  final bool isArchived;
  final String? otp;
  final DateTime? otpExpiry;
  final String? profileImage;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    bool? isArchived,
    String? otp,
    DateTime? otpExpiry,
    String? profileImage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        createdAt,
        updatedAt,
        authStatus,
        isArchived,
        otp,
        otpExpiry,
        profileImage,
      ];
}

/// Represents the user roles available within the desktop application.
/// This doesn't represent their position within the department.
/// The user role within the department is defined within the Officer model.
enum Role {
  admin,
  supplyCustodian,
}

/// Concrete User Classes
class SupplyDepartmentEmployee extends User {
  const SupplyDepartmentEmployee({
    required super.id, // id from parent class
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
    required this.employeeId,
    required this.role,
  });

  final String employeeId;
  final Role role;

  /// Create SupplyDepartmentEmployee Object out of json/ map data
  factory SupplyDepartmentEmployee.fromJson(Map<String, dynamic> json) {
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

    /// should strictly match with the keys on response
    return SupplyDepartmentEmployee(
      id: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      authStatus: authStatus,
      isArchived: json['is_archived'] as bool,
      otp: json['otp'] != null ? json['otp'] as String : null,
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'] as String)
          : null,
      profileImage: json['profile_image'] != null
          ? json['profile_image'] as String
          : null,
      employeeId: json['supp_dept_emp_id'] as String,
      role: role,
    );
  }

  /// Convert SupplyDepartmentEmployee Object to json/ map data
  Map<String, dynamic> toJson() => {
        'user_id': id,
        'name': name,
        'email': email,
        'password': password,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'auth_status': authStatus.toString().split('.').last,
        'is_archived': isArchived,
        'otp': otp,
        'otp_expiry': otpExpiry?.toIso8601String(),
        'profile_image': profileImage,
        'supp_dept_emp_id': employeeId,
        'role': role
            .toString()
            .split('.')
            .last, // extract the last and serialize it as a String
      };

  @override
  SupplyDepartmentEmployee copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    bool? isArchived,
    String? otp,
    DateTime? otpExpiry,
    String? profileImage,
    String? employeeId,
    Role? role,
  }) {
    return SupplyDepartmentEmployee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authStatus: authStatus ?? this.authStatus,
      isArchived: isArchived ?? this.isArchived,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      profileImage: profileImage ?? this.profileImage,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        createdAt,
        updatedAt,
        authStatus,
        isArchived,
        otp,
        otpExpiry,
        profileImage,
        employeeId,
        role,
      ];
}

enum AdminApprovalStatus {
  pending,
  accepted,
  rejected,
}

class MobileUser extends User {
  const MobileUser({
    required super.id, // corresponds to the base user id
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
    required this.mobileUserId,
    required this.officer,
    this.adminApprovalStatus = AdminApprovalStatus.pending,
  });

  final String mobileUserId;
  final Officer officer;
  final AdminApprovalStatus
      adminApprovalStatus; // represents admin approval of the account

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    final authStatusString = json['auth_status'] as String;
    final adminApprovalStatusString = json['admin_approval_status'] as String;

    print(json);
    // remove the prefix value in enums if present
    final authStatusValue = authStatusString.startsWith('AuthStatus.')
        ? authStatusString.substring(10)
        : authStatusString;

    // extract the last part of the role then compare to the retrieved role String
    final authStatus = AuthStatus.values.firstWhere(
      (e) => e.toString().split('.').last == authStatusValue,
      orElse: () => AuthStatus.unauthenticated,
    );

    final adminApprovalStatus = AdminApprovalStatus.values.firstWhere(
      (e) => e.toString().split('.').last == adminApprovalStatusString,
    );

    print(json);

    final mobileUser = MobileUser(
      id: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      authStatus: authStatus,
      isArchived: json['is_archived'] as bool,
      otp: json['otp'] != null ? json['otp'] as String : null,
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'] as String)
          : null,
      profileImage: json['profile_image'] != null
          ? json['profile_image'] as String
          : null,
      mobileUserId: json['mobile_user_id'] as String,
      officer: Officer.fromJson({
        'id': json['officer_id'],
        'user_id': json['officer_user_id'],
        'name': json['officer_name'],
        'position_id': json['position_id'],
        'office_name': json['office_name'],
        'position_name': json['position_name'],
        'is_archived': json['officer_is_archived'],
      }),
      adminApprovalStatus: adminApprovalStatus,
    );

    print(mobileUser);

    return mobileUser;
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'name': name,
        'email': email,
        'password': password,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'auth_status': authStatus.toString().split('.').last,
        'is_archived': isArchived,
        'otp': otp,
        'otp_expiry': otpExpiry?.toIso8601String(),
        'profile_image': profileImage,
        'mobile_user_id': mobileUserId,
        'officer': officer.toJson(),
        'admin_approval_status': adminApprovalStatus.toString().split('.').last,
      };

  MobileUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    bool? isArchived,
    String? otp,
    DateTime? otpExpiry,
    String? profileImage,
    String? mobileUserId,
    Officer? officer,
  }) {
    return MobileUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authStatus: authStatus ?? this.authStatus,
      isArchived: isArchived ?? this.isArchived,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      profileImage: profileImage ?? this.profileImage,
      mobileUserId: mobileUserId ?? this.mobileUserId,
      officer: officer ?? this.officer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        createdAt,
        updatedAt,
        authStatus,
        isArchived,
        otp,
        otpExpiry,
        profileImage,
        mobileUserId,
        officer,
        adminApprovalStatus,
      ];
}
