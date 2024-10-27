import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/entities/paginated_user_result.dart';
import '../../domain/entities/paginated_mobile_user_result_entity.dart';
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
    String? role,
    AuthStatus? status,
    AdminApprovalStatus? adminApprovalStatus,
    bool? isArchived,
  }) async {
    try {
      final paginatedUserModel =
          await usersManagementRemoteDataSource.getAllUsers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        sortBy: sortBy,
        sortAscending: sortAscending,
        role: role,
        status: status,
        adminApprovalStatus: adminApprovalStatus,
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
  Future<Either<Failure, PaginatedMobileUserResultEntity>> getPendingUsers({
    required int page,
    required int pageSize,
  }) async {
    try {
      final paginatedUserModel =
      await usersManagementRemoteDataSource.getPendingUsers(
        page: page,
        pageSize: pageSize,
      );

      return right(paginatedUserModel);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUserAuthenticationStatus({
    required String id,
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

  @override
  Future<Either<Failure, bool>> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final response =
      await usersManagementRemoteDataSource.updateUserArchiveStatus(
        id: id,
        isArchived: isArchived,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus adminApprovalStatus,
  }) async {
    try {
      final response =
      await usersManagementRemoteDataSource.updateAdminApprovalStatus(
        id: id,
        adminApprovalStatus: adminApprovalStatus,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
