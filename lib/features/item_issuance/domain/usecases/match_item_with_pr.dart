import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/matched_item_with_pr.dart';
import '../repository/issuance_repository.dart';

class MatchItemWithPr implements UseCase<MatchedItemWithPrEntity, String> {
  const MatchItemWithPr({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, MatchedItemWithPrEntity>> call(String param) async {
    return await issuanceRepository.matchItemWithPr(
      prId: param,
    );
  }
}
