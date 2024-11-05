import '../../../officer/domain/entities/officer.dart';
import '../../../purchase_request/domain/entities/purchase_request.dart';

abstract class IssuanceEntity {
  const IssuanceEntity({
    required this.id,
    required this.items,
    required this.purchaseRequestEntity,
    required this.officerEntity,
    required this.issuedDate,
    required this.returnDate,
    required this.isArchived,
  });

  final String id;
  final List<IssuanceEntity> items;
  final PurchaseRequestEntity purchaseRequestEntity;
  final OfficerEntity officerEntity;
  final DateTime issuedDate;
  final DateTime? returnDate;
  final bool isArchived;
}
