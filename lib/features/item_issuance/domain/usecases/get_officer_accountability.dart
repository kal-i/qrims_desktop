import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GetOfficerAccountability
    implements
        UseCase<List<Map<String, dynamic>>, GetOfficerAccountabilityParams> {
  const GetOfficerAccountability({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GetOfficerAccountabilityParams params,
  ) async {
    return await issuanceRepository.getOfficerAccountability(
      officerId: params.officerId,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
    );
  }
}

class GetOfficerAccountabilityParams {
  const GetOfficerAccountabilityParams({
    required this.officerId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  final String officerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
}
