import 'package:fpdart/fpdart.dart';

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
    required String prId,
    required List<dynamic> issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  });

  Future<Either<Failure, PropertyAcknowledgementReceiptEntity>> createPAR({
    required String prId,
    required List<dynamic> issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  });

  Future<Either<Failure, RequisitionAndIssueSlipEntity>> createRIS({
    required String prId,
    required List<dynamic> issuanceItems,
    String? purpose,
    String? responsibilityCenterCode,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String approvingOfficerOffice,
    required String approvingOfficerPosition,
    required String approvingOfficerName,
    required String issuingOfficerOffice,
    required String issuingOfficerPosition,
    required String issuingOfficerName,
  });

  Future<Either<Failure, IssuanceEntity?>> getIssuanceById({
    required String id,
  });

  Future<Either<Failure, bool>> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  });
}
