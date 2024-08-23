import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

// TODO: Modify the schemas - DONE
// TODO: Update the data models - DONE
// TODO: Update the user repository - (repo the one interacting with the db) - DONE

enum AuthStatus {
  unauthenticated,
  authenticated,
  revoked,
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
    this.otp,
    this.otpExpiry,
    this.profileImage,
  });

  final int id;
  final String name;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final AuthStatus authStatus;
  final String? otp;
  final DateTime? otpExpiry;
  final Uint8List? profileImage;

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    String? otp,
    DateTime? otpExpiry,
    Uint8List? profileImage,
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
        otp,
        otpExpiry,
        profileImage,
      ];
}

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
    super.otp,
    super.otpExpiry,
    super.profileImage,
    required this.employeeId,
    required this.role,
  });

  final int employeeId;
  final Role role;

  /// Create SupplyDepartmentEmployee Object out of json/ map data
  factory SupplyDepartmentEmployee.fromJson(Map<String, dynamic> json) {
    final authStatusString = json['auth_status'] as String;
    final roleString = json['role'] as String;

    print('AuthStatus string from JSON: $authStatusString');
    print('Role string from JSON: $roleString');

    // remove the prefix value in enums if present
    final authStatusValue = authStatusString.startsWith('AuthStatus.') ? authStatusString.substring(10) : authStatusString;
    final roleValue = roleString.startsWith('Role.') ? roleString.substring(5) : roleString;

    print('processed AuthStatus String: $authStatusValue');
    print('processed role string: $roleValue');

    // extract the last part of the role then compare to the retrieved role String
    final authStatus = AuthStatus.values.firstWhere((e) => e.toString().split('.').last == authStatusValue, orElse: () => AuthStatus.unauthenticated,);
    final role = Role.values.firstWhere(
      (e) => e.toString().split('.').last == roleValue,
      orElse: () => Role.supplyCustodian,
    );

    print('AuthStatus after conversion: $authStatus');
    print('Role after conversion: $role');

    /// should strictly match with the keys on response
    return SupplyDepartmentEmployee(
      id: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      authStatus: authStatus,
      otp: json['otp'] != null ? json['otp'] as String : null,
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'] as String)
          : null,
      profileImage: json['profile_image'] != null ? base64Decode(json['profile_image'] as String) : null,
      employeeId: json['supp_dept_emp_id'] as int,
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
        'otp': otp,
        'otp_expiry': otpExpiry?.toIso8601String(),
        'profile_image': profileImage != null ? base64Encode(profileImage!) : null,
        'supp_dept_emp_id': employeeId,
        'role': role
            .toString()
            .split('.')
            .last, // extract the last and serialize it as a String
      };

  @override
  SupplyDepartmentEmployee copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    String? otp,
    DateTime? otpExpiry,
    Uint8List? profileImage,
    int? employeeId,
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
        otp,
        otpExpiry,
        profileImage,
        employeeId,
        role,
      ];
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
    super.otp,
    super.otpExpiry,
    super.profileImage,
    required this.mobileUserId,
  });

  final int mobileUserId;

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    final authStatusString = json['auth_status'] as String;

    print('AuthStatus string from JSON: $authStatusString');

    // remove the prefix value in enums if present
    final authStatusValue = authStatusString.startsWith('AuthStatus.') ? authStatusString.substring(10) : authStatusString;

    print('processed AuthStatus String: $authStatusValue');

    // extract the last part of the role then compare to the retrieved role String
    final authStatus = AuthStatus.values.firstWhere((e) => e.toString().split('.').last == authStatusValue, orElse: () => AuthStatus.unauthenticated,);

    print('AuthStatus after conversion: $authStatus');
    
    return MobileUser(
      id: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      authStatus: authStatus,
      otp: json['otp'] != null ? json['otp'] as String : null,
      otpExpiry: json['otp_expiry'] != null
          ? DateTime.parse(json['otp_expiry'] as String)
          : null,
      profileImage: json['profile_image'] != null ? base64Decode(json['profile_image'] as String) : null,
      mobileUserId: json['mobile_user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'name': name,
        'email': email,
        'password': password,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'auth_status': authStatus.toString().split('.').last,
        'otp': otp,
        'otp_expiry': otpExpiry?.toIso8601String(),
        'profile_image': profileImage != null ? base64Encode(profileImage!) : null,
        'mobile_user_id': mobileUserId,
      };

  MobileUser copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    AuthStatus? authStatus,
    String? otp,
    DateTime? otpExpiry,
    Uint8List? profileImage,
    int? mobileUserId,
  }) {
    return MobileUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authStatus: authStatus ?? this.authStatus,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      profileImage: profileImage ?? this.profileImage,
      mobileUserId: mobileUserId ?? this.mobileUserId,
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
        otp,
        otpExpiry,
        profileImage,
        mobileUserId,
      ];
}
