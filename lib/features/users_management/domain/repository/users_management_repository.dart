import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/entities/paginated_user_result.dart';

abstract class UsersManagementRepository {
  Future<Either<Failure, PaginatedUserResultEntity>> geAllUsers({
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

  Future<Either<Failure, bool>> updateUserAuthenticationStatus({
    required String id,
    required AuthStatus authStatus,
  });

  Future<Either<Failure, bool>> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  });

  Future<Either<Failure, bool>> updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus adminApprovalStatus,
  });
}
