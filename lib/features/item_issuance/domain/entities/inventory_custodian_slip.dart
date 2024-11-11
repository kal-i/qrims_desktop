import '../../../officer/domain/entities/officer.dart';
import 'issuance.dart';

class InventoryCustodianSlipEntity extends IssuanceEntity {
  const InventoryCustodianSlipEntity({
    required super.id,
    required this.icsId,
    required super.items,
    required super.purchaseRequestEntity,
    required super.issuedDate,
    super.returnDate,
    required super.receivingOfficerEntity,
    required this.sendingOfficerEntity,
    required super.qrCodeImageData,
    super.isReceived,
    super.isArchived,
  });

  final String icsId;
  final OfficerEntity sendingOfficerEntity;
}
