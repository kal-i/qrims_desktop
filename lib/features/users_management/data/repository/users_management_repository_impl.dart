import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/paginated_user_result.dart';
import '../../domain/repository/users_management_repository.dart';
import '../data_sources/remote/users_management_remote_data_source.dart';

class UsersManagementRepositoryImpl implements UsersManagementRepository {
  const UsersManagementRepositoryImpl({
    required this.usersManagementRemoteDataSource,
  });

  final UsersManagementRemoteDataSource usersManagementRemoteDataSource;

  @override
  Future<Either<Failure, PaginatedUserResultEntity>> geAllUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? filter,
  }) async {
    try {
      final paginatedUserModel =
          await usersManagementRemoteDataSource.getAllUsers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortAscending: sortAscending,
        filter: filter,
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
  Future<Either<Failure, bool>> updateUserAuthenticationStatus({
    required int id,
    required AuthStatus authStatus,
  }) async {
    try {
      final response =
          await usersManagementRemoteDataSource.updateUserAuthenticationStatus(
        id: id,
        authStatus: authStatus,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
