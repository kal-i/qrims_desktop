import 'issuance.dart';

class PropertyAcknowledgementReceiptEntity extends IssuanceEntity {
  const PropertyAcknowledgementReceiptEntity({
    required super.id,
    required this.parId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  final String parId;
}
