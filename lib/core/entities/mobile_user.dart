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
    super.isArchived,
    super.otp,
    super.otpExpiry,
    super.profileImage,
    required this.mobileUserId,
  });

  final String mobileUserId;

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
      ];
}
