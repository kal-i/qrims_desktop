import 'issuance.dart';

class InventoryCustodianSlipEntity extends IssuanceEntity {
  const InventoryCustodianSlipEntity({
    required super.id,
    required this.icsId,
    required super.issuedDate,
    super.returnDate,
    required super.items,
    //super.batchItems,
    super.purchaseRequestEntity,
    super.entity,
    super.fundCluster,
    super.receivingOfficerEntity,
    super.issuingOfficerEntity,
    required super.qrCodeImageData,
    super.status,
    super.isArchived,
  });

  final String icsId;
}
