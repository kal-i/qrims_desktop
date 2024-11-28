import 'package:fpdart/src/either.dart';

import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/purchase_request_repository.dart';

class UpdatePurchaseRequestStatus
    implements UseCase<bool, UpdatePurchaseRequestsStatusParams> {
  const UpdatePurchaseRequestStatus({
    required this.purchaseRequestRepository,
  });

  final PurchaseRequestRepository purchaseRequestRepository;

  @override
  Future<Either<Failure, bool>> call(
      UpdatePurchaseRequestsStatusParams params) async {
    return await purchaseRequestRepository.updatePurchaseRequestStatus(
      id: params.id,
      status: params.status,
    );
  }
}

class UpdatePurchaseRequestsStatusParams {
  const UpdatePurchaseRequestsStatusParams({
    required this.id,
    required this.status,
  });

  final String id;
  final PurchaseRequestStatus status;
}
