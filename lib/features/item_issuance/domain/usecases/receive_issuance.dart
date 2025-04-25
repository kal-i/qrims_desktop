import 'package:fpdart/src/either.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/issuance_repository.dart';

class ReceiveIssuance implements UseCase<bool, ReceiveIssuanceParams> {
  const ReceiveIssuance({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, bool>> call(
    ReceiveIssuanceParams params,
  ) {
    return issuanceRepository.receiveIssuance(
      baseIssuanceId: params.baseIssuanceId,
      receivingOfficerOffice: params.receivingOfficerOffice,
      receivingOfficerPosition: params.receivingOfficerPosition,
      receivingOfficerName: params.receivingOfficerName,
      receivedDate: params.receivedDate,
    );
  }
}

class ReceiveIssuanceParams {
  const ReceiveIssuanceParams({
    required this.baseIssuanceId,
    required this.receivingOfficerOffice,
    required this.receivingOfficerPosition,
    required this.receivingOfficerName,
    required this.receivedDate,
  });

  final String baseIssuanceId;
  final String receivingOfficerOffice;
  final String receivingOfficerPosition;
  final String receivingOfficerName;
  final DateTime receivedDate;
}
