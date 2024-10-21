import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/officer_repository.dart';

class UpdateOfficerArchiveStatus
    implements UseCase<bool, UpdateOfficerArchiveStatusParams> {
  const UpdateOfficerArchiveStatus({
    required this.officerRepository,
  });

  final OfficerRepository officerRepository;

  @override
  Future<Either<Failure, bool>> call(
      UpdateOfficerArchiveStatusParams params) async {
    return await officerRepository.updateOfficerArchiveStatus(
      id: params.id,
      isArchived: params.isArchived,
    );
  }
}

class UpdateOfficerArchiveStatusParams {
  const UpdateOfficerArchiveStatusParams(
      {required this.id, required this.isArchived});

  final String id;
  final bool isArchived;
}
