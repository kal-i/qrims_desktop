import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/inventory_custodian_slip.dart';
import '../entities/issuance.dart';
import '../entities/matched_item_with_pr.dart';
import '../entities/paginated_issuance_result.dart';
import '../entities/property_acknowledgement_receipt.dart';

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
    String? propertyNumber,
    required List<dynamic> issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  });

  Future<Either<Failure, IssuanceEntity?>> getIssuanceById({
    required String id,
  });
}
