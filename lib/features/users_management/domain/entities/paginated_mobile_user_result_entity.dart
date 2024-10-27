import '../../../../core/entities/mobile_user.dart';

class PaginatedMobileUserResultEntity {
  const PaginatedMobileUserResultEntity({
    required this.users,
    required this.totalUserCount,
  });

  final List<MobileUserEntity> users;
  final int totalUserCount;
}
