import '../../../../core/models/mobile_user.dart';
import '../../domain/entities/paginated_mobile_user_result_entity.dart';

class PaginatedMobileUserResultModel extends PaginatedMobileUserResultEntity {
  const PaginatedMobileUserResultModel({
    required super.users,
    required super.totalUserCount,
  });

  factory PaginatedMobileUserResultModel.fromJson(Map<String, dynamic> json) {
    return PaginatedMobileUserResultModel(
      users: (json['users'] as List<dynamic>)
          .map((user) => MobileUserModel.fromJson(user as Map<String, dynamic>))
          .toList(),
      totalUserCount: json['totalUserCount'],
    );
  }
}
