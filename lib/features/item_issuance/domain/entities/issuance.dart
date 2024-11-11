import '../../../officer/domain/entities/officer.dart';
import '../../../purchase_request/domain/entities/purchase_request.dart';
import 'issuance_item.dart';

abstract class IssuanceEntity {
  const IssuanceEntity({
    required this.id,
    required this.items,
    required this.purchaseRequestEntity,
    required this.receivingOfficerEntity,
    required this.issuedDate,
    this.returnDate,
    required this.qrCodeImageData,
    this.isReceived = false,
    this.isArchived = false,
  });

  final String id;
  final List<IssuanceItemEntity> items;
  final PurchaseRequestEntity purchaseRequestEntity;
  final OfficerEntity receivingOfficerEntity;
  final DateTime issuedDate;
  final DateTime? returnDate;
  final String qrCodeImageData;
  final bool isReceived;
  final bool isArchived;
}
