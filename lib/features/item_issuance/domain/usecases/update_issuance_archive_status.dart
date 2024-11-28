import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class UpdateIssuanceArchiveStatus
    implements UseCase<bool, UpdateIssuanceArchiveStatusParams> {
  const UpdateIssuanceArchiveStatus({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;
  @override
  Future<Either<Failure, bool>> call(
      UpdateIssuanceArchiveStatusParams params) async {
    return await issuanceRepository.updateIssuanceArchiveStatus(
      id: params.id,
      isArchived: params.isArchived,
    );
  }
}

class UpdateIssuanceArchiveStatusParams {
  const UpdateIssuanceArchiveStatusParams({
    required this.id,
    required this.isArchived,
  });

  final String id;
  final bool isArchived;
}
