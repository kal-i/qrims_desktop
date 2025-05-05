import 'package:fpdart/src/either.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GetAccountableOfficerId
    implements UseCase<String?, GetAccountableOfficerIdParams> {
  const GetAccountableOfficerId({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, String?>> call(
    GetAccountableOfficerIdParams params,
  ) async {
    return await issuanceRepository.getAccountableOfficerId(
      office: params.office,
      position: params.position,
      name: params.name,
    );
  }
}

class GetAccountableOfficerIdParams {
  const GetAccountableOfficerIdParams({
    required this.office,
    required this.position,
    required this.name,
  });

  final String office;
  final String position;
  final String name;
}
