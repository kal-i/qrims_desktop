import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_user_result.dart';
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
      filter: params.filter,
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
    this.filter,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final String? filter;
}
