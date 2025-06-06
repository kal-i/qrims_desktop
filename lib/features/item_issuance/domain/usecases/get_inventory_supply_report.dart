import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GetInventorySupplyReport
    implements UseCase<List<Map<String, dynamic>>, GenerateRPCIParams> {
  const GetInventorySupplyReport({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GenerateRPCIParams params,
  ) async {
    return await issuanceRepository.getInventorySupplyReport(
      startDate: params.startDate,
      endDate: params.endDate,
      fundCluster: params.fundCluster,
    );
  }
}

class GenerateRPCIParams {
  const GenerateRPCIParams({
    required this.startDate,
    this.endDate,
    this.fundCluster,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final FundCluster? fundCluster;
}
