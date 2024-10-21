import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/models/paginated_user_result.dart';

abstract class UsersManagementRemoteDataSource {
  
  Future<PaginatedUserResultModel> getAllUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? role,
    AuthStatus? status,
    bool? isArchived,
  });

  Future<bool> updateUserAuthenticationStatus({
    required String id,
    required AuthStatus authStatus,
  });

  Future<bool> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  });
}
