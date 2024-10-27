import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_mobile_user_result_entity.dart';
import '../repository/users_management_repository.dart';

class GetPendingUsers implements UseCase<PaginatedMobileUserResultEntity, GetPendingUsersParams> {
  const GetPendingUsers({
    required this.usersManagementRepository,
  });

  final UsersManagementRepository usersManagementRepository;

  @override
  Future<Either<Failure, PaginatedMobileUserResultEntity>> call(GetPendingUsersParams params) async {
    return await usersManagementRepository.getPendingUsers(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetPendingUsersParams {
  const GetPendingUsersParams({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}
