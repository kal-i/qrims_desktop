import 'package:fpdart/fpdart.dart';

import '../../../../../core/entities/paginated_user_result.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/error/failure.dart';

abstract interface class ArchiveUsersRepository {
  Future<Either<Failure, PaginatedUserResultEntity>> getArchivedUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? role,
    AuthStatus? authStatus,
    required bool isArchived,
  });

  Future<Either<Failure, bool>> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  });
}
