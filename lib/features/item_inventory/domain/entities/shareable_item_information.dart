import '../../../../core/enums/unit.dart';

class ShareableItemInformationEntity {
  const ShareableItemInformationEntity({
    required this.id,
    required this.productNameId,
    required this.productDescriptionId,
    required this.specification,
    required this.unit,
    required this.quantity,
    required this.encryptedId,
    required this.qrCodeImageData,
  });

  final String id;
  final String productNameId;
  final String productDescriptionId;
  final String specification;
  final Unit unit;
  final int quantity;
  final String encryptedId;
  final String qrCodeImageData;
}
