import '../../../../../../core/enums/auth_status.dart';
import '../../../../../../core/models/paginated_user_result.dart';

abstract interface class ArchiveUsersRemoteDataSource {

  Future<PaginatedUserResultModel> getArchivedUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? role,
    AuthStatus? authStatus,
    required bool isArchived,
  });

  Future<bool> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  });
}