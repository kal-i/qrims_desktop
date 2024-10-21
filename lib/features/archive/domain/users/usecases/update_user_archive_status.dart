import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repository/archive_users_repository.dart';

class UpdateUserIsArchiveStatus
    implements UseCase<bool, UpdateUserArchiveStatusParams> {
  const UpdateUserIsArchiveStatus({
    required this.archiveUserRepository,
  });

  final ArchiveUsersRepository archiveUserRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateUserArchiveStatusParams params) async {
    return await archiveUserRepository.updateUserArchiveStatus(
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
