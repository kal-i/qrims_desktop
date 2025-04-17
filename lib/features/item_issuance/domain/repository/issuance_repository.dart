import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/error/failure.dart';
import '../entities/inventory_custodian_slip.dart';
import '../entities/issuance.dart';
import '../entities/matched_item_with_pr.dart';
import '../entities/paginated_issuance_result.dart';
import '../entities/property_acknowledgement_receipt.dart';
import '../entities/requisition_and_issue_slip.dart';

abstract interface class IssuanceRepository {
  Future<Either<Failure, PaginatedIssuanceResultEntity>> getIssuances({
    required int page,
    required int pageSize,
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool? isArchived,
  });

  Future<Either<Failure, MatchedItemWithPrEntity>> matchItemWithPr({
    required String prId,
  });

  Future<Either<Failure, InventoryCustodianSlipEntity>> createICS({
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

  Future<Either<Failure, PropertyAcknowledgementReceiptEntity>> createPAR({
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

  Future<Either<Failure, RequisitionAndIssueSlipEntity>> createRIS({
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

  Future<Either<Failure, IssuanceEntity?>> getIssuanceById({
    required String id,
  });

  Future<Either<Failure, bool>> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getInventorySupplyReport({
    required DateTime startDate,
    DateTime? endDate,
    FundCluster? fundCluster,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>>
      getInventorySemiExpendablePropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>>
      getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>>
      generateSemiExpendablePropertyCardData({
    required String icsId,
    required FundCluster fundCluster,
  });
}
