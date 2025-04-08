import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class GenerateSemiExpendablePropertyCardData
    implements
        UseCase<List<Map<String, dynamic>>,
            GenerateSemiExpendablePropertyCardDataParams> {
  const GenerateSemiExpendablePropertyCardData({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
      GenerateSemiExpendablePropertyCardDataParams params) async {
    return await issuanceRepository.generateSemiExpendablePropertyCardData(
      icsId: params.icsId,
      fundCluster: params.fundCluster,
    );
  }
}

class GenerateSemiExpendablePropertyCardDataParams {
  const GenerateSemiExpendablePropertyCardDataParams({
    required this.icsId,
    required this.fundCluster,
  });

  final String icsId;
  final FundCluster fundCluster;
}
