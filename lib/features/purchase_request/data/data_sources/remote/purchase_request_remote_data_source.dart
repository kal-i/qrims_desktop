import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/purchase_request_status.dart';
import '../../models/paginated_purchase_request_result.dart';
import '../../models/purchase_request.dart';
import '../../models/purchase_request_with_notification_trail.dart';

abstract interface class PurchaseRequestRemoteDataSource {
  Future<PurchaseRequestModel> registerPurchaseRequest({
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

  Future<PaginatedPurchaseRequestResultModel> getPurchaseRequests({
    required int page,
    required int pageSize,
    String? prId,
    String? requestingOfficerName,
    String? search,
    double? unitCost,
    DateTime? startDate,
    DateTime? endDate,
    PurchaseRequestStatus? prStatus,
    bool? isArchived,
  });

  Future<bool> updatePurchaseRequestStatus({
    required String id,
    required PurchaseRequestStatus status,
  });

  Future<PurchaseRequestWithNotificationTrailModel> getPurchaseRequestById({
    required String prId,
  });
}
