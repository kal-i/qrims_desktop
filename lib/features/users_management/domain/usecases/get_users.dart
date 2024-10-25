import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/entities/paginated_user_result.dart';
import '../repository/users_management_repository.dart';

class GetUsers implements UseCase<PaginatedUserResultEntity, GetUsersParams> {
  const GetUsers({
    required this.usersManagementRepository,
  });

  final UsersManagementRepository usersManagementRepository;

  @override
  Future<Either<Failure, PaginatedUserResultEntity>> call(GetUsersParams params) async {
    return await usersManagementRepository.geAllUsers(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
      sortAscending: params.sortAscending,
      role: params.role,
      status: params.status,
      adminApprovalStatus: params.adminApprovalStatus,
      isArchived: params.isArchived,
    );
  }
}

class GetUsersParams {
  const GetUsersParams({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.role,
    this.status,
    this.adminApprovalStatus,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final String? role;
  final AuthStatus? status;
  final AdminApprovalStatus? adminApprovalStatus;
  final bool? isArchived;
}
