import 'package:fpdart/src/either.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GetInventoryPropertyReport
    implements UseCase<List<Map<String, dynamic>>, GenerateRPPEParams> {
  const GetInventoryPropertyReport({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GenerateRPPEParams params,
  ) async {
    return await issuanceRepository.getInventoryPropertyReport(
      startDate: params.startDate,
      endDate: params.endDate,
      assetSubClass: params.assetSubClass,
      fundCluster: params.fundCluster,
    );
  }
}

class GenerateRPPEParams {
  const GenerateRPPEParams({
    required this.startDate,
    this.endDate,
    this.assetSubClass,
    this.fundCluster,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final AssetSubClass? assetSubClass;
  final FundCluster? fundCluster;
}
