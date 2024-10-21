import 'package:equatable/equatable.dart';

import '../../../../core/enums/auth_status.dart';

abstract class UserEntity extends Equatable {
  const UserEntity({
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
