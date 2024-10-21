import 'package:fpdart/fpdart.dart';

import '../../../../../core/entities/paginated_user_result.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repository/archive_users_repository.dart';

class GetArchivedUsers implements UseCase<PaginatedUserResultEntity, GetArchiveUsersParams> {
  const GetArchivedUsers({
    required this.archiveUserRepository,
  });

  final ArchiveUsersRepository archiveUserRepository;

  @override
  Future<Either<Failure, PaginatedUserResultEntity>> call(GetArchiveUsersParams params) async {
    return await archiveUserRepository.getArchivedUsers(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      role: params.role,
      authStatus: params.status,
      isArchived: params.isArchived,
    );
  }
}

class GetArchiveUsersParams {
  const GetArchiveUsersParams({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.role,
    this.status,
    required this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? role;
  final AuthStatus? status;
  final bool isArchived;
}
