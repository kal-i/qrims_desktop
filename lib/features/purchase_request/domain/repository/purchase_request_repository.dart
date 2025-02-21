import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/error/failure.dart';
import '../entities/paginated_purchase_request_result.dart';
import '../entities/purchase_request.dart';
import '../entities/purchase_request_with_notification_trail.dart';

abstract interface class PurchaseRequestRepository {
  Future<Either<Failure, PurchaseRequestEntity>> registerPurchaseRequest({
    required String entityName,
    required FundCluster fundCluster,
    required String officeName,
    required DateTime date,
    required List<Map<String, dynamic>> requestedItems,
    required String purpose,
    required String requestingOfficerOffice,
    required String requestingOfficerPosition,
    required String requestingOfficerName,
    required String approvingOfficerOffice,
    required String approvingOfficerPosition,
    required String approvingOfficerName,
  });

  Future<Either<Failure, PaginatedPurchaseRequestResultEntity>>
      getPurchaseRequests({
    required int page,
    required int pageSize,
    String? prId,
    double? unitCost,
    DateTime? startDate,
    DateTime? endDate,
    PurchaseRequestStatus? prStatus,
    bool? isArchived,
  });

  Future<Either<Failure, bool>> updatePurchaseRequestStatus({
    required String id,
    required PurchaseRequestStatus status,
  });

  Future<Either<Failure, PurchaseRequestWithNotificationTrailEntity>>
      getPurchaseRequestById({
    required String prId,
  });
}
