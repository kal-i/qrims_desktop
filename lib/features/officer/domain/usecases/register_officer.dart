import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/officer.dart';
import '../repository/officer_repository.dart';

class RegisterOfficer implements UseCase<OfficerEntity, RegisterOfficerParams> {
  const RegisterOfficer({
    required this.officerRepository,
  });

  final OfficerRepository officerRepository;

  @override
  Future<Either<Failure, OfficerEntity>> call(params) async {
    return await officerRepository.registerOfficer(
      name: params.name,
      officeName: params.officeName,
      positionName: params.positionName,
    );
  }
}

class RegisterOfficerParams {
  const RegisterOfficerParams({
    required this.name,
    required this.officeName,
    required this.positionName,
  });

  final String name;
  final String officeName;
  final String positionName;
}
