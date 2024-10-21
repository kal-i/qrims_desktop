import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/users_management_repository.dart';

class UpdateUserArchiveStatus
    implements UseCase<bool, UpdateUserArchiveStatusParams> {
  const UpdateUserArchiveStatus({
    required this.usersManagementRepository,
  });

  final UsersManagementRepository usersManagementRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateUserArchiveStatusParams params) async {
    return await usersManagementRepository.updateUserArchiveStatus(
      id: params.id,
      isArchived: params.isArchived,
    );
  }
}

class UpdateUserArchiveStatusParams {
  const UpdateUserArchiveStatusParams({
    required this.id,
    required this.isArchived,
  });

  final String id;
  final bool isArchived;
}
