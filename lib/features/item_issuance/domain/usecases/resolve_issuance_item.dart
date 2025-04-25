import 'package:fpdart/src/either.dart';

import '../../../../core/enums/issuance_item_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class ResolveIssuanceItem implements UseCase<bool, ResolveIssuanceItemParams> {
  const ResolveIssuanceItem({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, bool>> call(
    ResolveIssuanceItemParams params,
  ) {
    return issuanceRepository.resolveIssuanceItem(
      baseItemId: params.baseItemId,
      status: params.status,
      date: params.date,
      remarks: params.remarks,
    );
  }
}

class ResolveIssuanceItemParams {
  const ResolveIssuanceItemParams({
    required this.baseItemId,
    required this.status,
    required this.date,
    this.remarks,
  });

  final String baseItemId;
  final IssuanceItemStatus status;
  final DateTime date;
  final String? remarks;
}
