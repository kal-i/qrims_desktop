import 'package:fpdart/src/either.dart';

import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_purchase_request_result.dart';
import '../repository/purchase_request_repository.dart';

class GetPaginatedPurchaseRequests
    implements
        UseCase<PaginatedPurchaseRequestResultEntity,
            GetPaginatedPurchaseRequestsParams> {
  const GetPaginatedPurchaseRequests({
    required this.purchaseRequestRepository,
  });

  final PurchaseRequestRepository purchaseRequestRepository;

  @override
  Future<Either<Failure, PaginatedPurchaseRequestResultEntity>> call(
      GetPaginatedPurchaseRequestsParams params) async {
    return purchaseRequestRepository.getPurchaseRequests(
      page: params.page,
      pageSize: params.pageSize,
      prId: params.prId,
      unitCost: params.unitCost,
      date: params.date,
      prStatus: params.prStatus,
      isArchived: params.isArchived,
    );
  }
}

class GetPaginatedPurchaseRequestsParams {
  const GetPaginatedPurchaseRequestsParams({
    required this.page,
    required this.pageSize,
    required this.prId,
    required this.unitCost,
    required this.date,
    required this.prStatus,
    required this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? prId;
  final double? unitCost;
  final DateTime? date;
  final PurchaseRequestStatus? prStatus;
  final bool? isArchived;
}