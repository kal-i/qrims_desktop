import '../../../../core/models/user.dart';
import '../../domain/entities/paginated_user_result.dart';

class PaginatedUserResultModel extends PaginatedUserResultEntity {
  const PaginatedUserResultModel({
    required super.users,
    required super.totalUserCount,
  });

  factory PaginatedUserResultModel.fromJson(Map<String, dynamic> json) {
    return PaginatedUserResultModel(
      users: (json['users'] as List<dynamic>)
          .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
          .toList(),
      totalUserCount: json['totalUserCount'],
    );
  }
}
