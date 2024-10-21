import 'package:fpdart/src/either.dart';

import '../../../../../core/entities/paginated_user_result.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/users/repository/archive_users_repository.dart';
import '../data_sources/remote/archive_users_remote_data_source.dart';

class ArchiveUsersRepositoryImpl implements ArchiveUsersRepository {
  const ArchiveUsersRepositoryImpl({
    required this.archiveUserRemoteDataSource,
  });

  final ArchiveUsersRemoteDataSource archiveUserRemoteDataSource;

  @override
  Future<Either<Failure, PaginatedUserResultEntity>> getArchivedUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? role,
    AuthStatus? authStatus,
    required bool isArchived,
  }) async {
    try {
      final paginatedUserModel =
          await archiveUserRemoteDataSource.getArchivedUsers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        role: role,
        authStatus: authStatus,
        isArchived: isArchived,
      );

      print(paginatedUserModel.totalUserCount);
      print(paginatedUserModel.users);

      print('umr_impl: $paginatedUserModel');
      return right(paginatedUserModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final response =
          await archiveUserRemoteDataSource.updateUserArchiveStatus(
        id: id,
        isArchived: isArchived,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
