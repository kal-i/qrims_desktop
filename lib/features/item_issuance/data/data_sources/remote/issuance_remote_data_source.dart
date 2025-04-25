import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/ics_type.dart';
import '../../../../../core/enums/issuance_item_status.dart';
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
    String? supplierName,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  });

  Future<List<InventoryCustodianSlipModel>> createMultipleICS({
    DateTime? issuedDate,
    IcsType? type,
    required List<dynamic> receivingOfficers,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  });

  Future<PropertyAcknowledgementReceiptModel> createPAR({
    DateTime? issuedDate,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  });

  Future<List<PropertyAcknowledgementReceiptModel>> createMultiplePAR({
    DateTime? issuedDate,
    required List<dynamic> receivingOfficers,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
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
    DateTime? receivedDate,
    DateTime? approvedDate,
    DateTime? requestDate,
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
    FundCluster? fundCluster,
  });

  Future<List<Map<String, dynamic>>> getInventorySemiExpendablePropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  });

  Future<List<Map<String, dynamic>>> getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  });

  Future<List<Map<String, dynamic>>> generateSemiExpendablePropertyCardData({
    required String icsId,
    required FundCluster fundCluster,
  });

  Future<bool> receiveIssuance({
    required String baseIssuanceId,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required DateTime receivedDate,
  });

  Future<List<Map<String, dynamic>>> getOfficerAccountability({
    required String officerId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<bool> resolveIssuanceItem({
    required String baseItemId,
    required IssuanceItemStatus status,
    required DateTime date,
    String? remarks,
  });
}
