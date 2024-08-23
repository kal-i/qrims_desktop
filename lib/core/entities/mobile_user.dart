import 'user.dart';

class MobileUserEntity extends UserEntity {
  const MobileUserEntity({
    required super.id,
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
