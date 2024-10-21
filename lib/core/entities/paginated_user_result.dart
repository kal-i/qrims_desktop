import 'user.dart';

class PaginatedUserResultEntity {
  const PaginatedUserResultEntity({
    required this.users,
    required this.totalUserCount,
  });

  final List<UserEntity> users;
  final int totalUserCount;
}
