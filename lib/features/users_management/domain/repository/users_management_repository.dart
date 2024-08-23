import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../entities/paginated_user_result.dart';

abstract class UsersManagementRepository {
  Future<Either<Failure, PaginatedUserResultEntity>> geAllUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? filter,
  });

  Future<Either<Failure, bool>> updateUserAuthenticationStatus({
    required int id,
    required AuthStatus authStatus,
  });
}
