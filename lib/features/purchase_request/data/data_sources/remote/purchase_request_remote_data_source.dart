import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/purchase_request_status.dart';
import '../../../../../core/enums/unit.dart';
import '../../models/paginated_purchase_request_result.dart';
import '../../models/purchase_request.dart';

abstract interface class PurchaseRequestRemoteDataSource {

  Future<PurchaseRequestModel> registerPurchaseRequest({
    required String entityName,
    required FundCluster fundCluster,
    required String officeName,
    String? responsibilityCenterCode,
    required DateTime date,
    required String productName,
    required String productDescription,
    required Unit unit,
    required int quantity,
    required double unitCost,
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
    double? unitCost,
    DateTime? date,
    PurchaseRequestStatus? prStatus,
    bool? isArchived,
  });
}