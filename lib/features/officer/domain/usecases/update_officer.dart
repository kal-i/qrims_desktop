import 'package:fpdart/src/either.dart';

import '../../../../core/enums/officer_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/officer_repository.dart';

class UpdateOfficer implements UseCase<bool, UpdateOfficerParams> {
  const UpdateOfficer({
    required this.officerRepository,
  });

  final OfficerRepository officerRepository;

  @override
  Future<Either<Failure, bool>> call(
    UpdateOfficerParams params,
  ) async {
    return await officerRepository.updateOfficer(
      id: params.id,
      office: params.office,
      position: params.position,
      name: params.name,
      status: params.status,
    );
  }
}

final class UpdateOfficerParams {
  const UpdateOfficerParams({
    required this.id,
    this.office,
    this.position,
    this.name,
    this.status,
  });

  final String id;
  final String? office;
  final String? position;
  final String? name;
  final OfficerStatus? status;
}
