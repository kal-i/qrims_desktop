import '../../../../../core/enums/auth_status.dart';
import '../../models/paginated_user_result.dart';

abstract class UsersManagementRemoteDataSource {
  
  Future<PaginatedUserResultModel> getAllUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? filter,
  });

  Future<bool> updateUserAuthenticationStatus({
    required int id,
    required AuthStatus authStatus,
  });
}
