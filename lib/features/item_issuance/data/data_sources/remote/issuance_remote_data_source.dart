import '../../models/inventory_custodian_slip.dart';
import '../../models/issuance.dart';
import '../../models/matched_item_with_pr.dart';
import '../../models/paginated_issuance_result.dart';
import '../../models/property_acknowledgement_receipt.dart';

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
    required String prId,
    required List<dynamic> issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  });

  Future<PropertyAcknowledgementReceiptModel> createPAR({
    required String prId,
    String? propertyNumber,
    required List<dynamic> issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  });

  Future<IssuanceModel?> getIssuanceById({
    required String id,
  });

  Future<bool> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  });
}
