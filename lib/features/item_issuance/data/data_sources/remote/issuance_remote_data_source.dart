import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/ics_type.dart';
import '../../models/inventory_custodian_slip.dart';
import '../../models/issuance.dart';
import '../../models/matched_item_with_pr.dart';
import '../../models/paginated_issuance_result.dart';
import '../../models/property_acknowledgement_receipt.dart';
import '../../models/requisition_and_issue_slip.dart';

abstract interface class IssuanceRemoteDataSource {
  Future<PaginatedIssuanceResultModel> getIssuances({
    required int page,
    required int pageSize,
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool? isArchived,
  });

  Future<MatchedItemWithPrModel> matchItemWithPr({
    required String prId,
  });

  Future<InventoryCustodianSlipModel> createICS({
    DateTime? issuedDate,
    IcsType? type,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
  });

  Future<PropertyAcknowledgementReceiptModel> createPAR({
    DateTime? issuedDate,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
  });

  Future<RequisitionAndIssuanceSlipModel> createRIS({
    DateTime? issuedDate,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? division,
    String? responsibilityCenterCode,
    String? officeName,
    String? purpose,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    String? approvingOfficerOffice,
    String? approvingOfficerPosition,
    String? approvingOfficerName,
    String? requestingOfficerOffice,
    String? requestingOfficerPosition,
    String? requestingOfficerName,
  });

  Future<IssuanceModel?> getIssuanceById({
    required String id,
  });

  Future<bool> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  });

  Future<List<Map<String, dynamic>>> getInventorySupplyReport({
    required DateTime startDate,
    DateTime? endDate,
  });

  Future<List<Map<String, dynamic>>> getInventorySemiExpendablePropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
  });

  Future<List<Map<String, dynamic>>> getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
  });
}
