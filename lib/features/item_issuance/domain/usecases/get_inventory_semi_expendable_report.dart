import 'package:fpdart/src/either.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GetInventorySemiExpendablePropertyReport
    implements UseCase<List<Map<String, dynamic>>, GenerateRPSEPParams> {
  const GetInventorySemiExpendablePropertyReport({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GenerateRPSEPParams params,
  ) async {
    return await issuanceRepository.getInventorySemiExpendablePropertyReport(
      startDate: params.startDate,
      endDate: params.endDate,
      assetSubClass: params.assetSubClass,
    );
  }
}

class GenerateRPSEPParams {
  const GenerateRPSEPParams({
    required this.startDate,
    this.endDate,
    this.assetSubClass,
  });

  final DateTime startDate;
  final DateTime? endDate;
  final AssetSubClass? assetSubClass;
}
