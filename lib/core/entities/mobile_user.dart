import '../../features/officer/domain/entities/officer.dart';
import '../enums/admin_approval_status.dart';
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
    required this.officerEntity,
    this.adminApprovalStatus = AdminApprovalStatus.pending,
  });

  final String mobileUserId;
  final OfficerEntity officerEntity;
  final AdminApprovalStatus adminApprovalStatus;

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
        officerEntity,
        adminApprovalStatus,
      ];
}
