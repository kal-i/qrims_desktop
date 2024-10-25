import '../../../../../core/enums/admin_approval_status.dart';
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
    AdminApprovalStatus? adminApprovalStatus,
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

  Future<bool> updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus adminApprovalStatus,
  });
}
