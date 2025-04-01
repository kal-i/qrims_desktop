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
      requestingOfficerName: params.requestingOfficerName,
      searchQuery: params.searchQuery,
      unitCost: params.unitCost,
      startDate: params.startDate,
      endDate: params.endDate,
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
    required this.requestingOfficerName,
    required this.searchQuery,
    required this.unitCost,
    required this.startDate,
    required this.endDate,
    required this.prStatus,
    required this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? prId;
  final String? requestingOfficerName;
  final String? searchQuery;
  final double? unitCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final PurchaseRequestStatus? prStatus;
  final bool? isArchived;
}
