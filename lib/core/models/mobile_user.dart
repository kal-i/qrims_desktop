import 'dart:convert';

import '../enums/auth_status.dart';
import '../entities/mobile_user.dart';
import 'user.dart';

class MobileUserModel extends MobileUserEntity implements UserModel {
  const MobileUserModel({
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
    required super.mobileUserId,
  });

  factory MobileUserModel.fromJson(Map<String, dynamic> json) {
    final authStatusString = json['auth_status'] as String;

    print('AuthStatus string from JSON: $authStatusString');

    // remove the prefix value in enums if present
    final authStatusValue = authStatusString.startsWith('AuthStatus.') ? authStatusString.substring(10) : authStatusString;

    print('processed AuthStatus String: $authStatusValue');

    // extract the last part of the role then compare to the retrieved role String
    final authStatus = AuthStatus.values.firstWhere((e) => e.toString().split('.').last == authStatusValue, orElse: () => AuthStatus.unauthenticated,);

    print('AuthStatus after conversion: $authStatus');

    return MobileUserModel(
      id: json['user_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : json['created_at'] as DateTime,
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : json['updated_at'],
      authStatus: authStatus,
      isArchived: json['is_archived'],
      otp: json['otp'],
      otpExpiry: json['otp_expiry'] is String ? DateTime.parse(json['otp_expiry'] as String) : json['otp_expiry'],
      profileImage: json['profile_image'] != null ? json['profile_image'] as String : null,
      mobileUserId: json['mobile_user_id'],
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
      'profile_image': profileImage,
      'mobile_user_id': mobileUserId,
    };
  }
}

// I badly need to fix the role