import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';

class ShareableItemInformationEntity {
  const ShareableItemInformationEntity({
    required this.id,
    required this.productNameId,
    required this.productDescriptionId,
    this.specification,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.encryptedId,
    required this.qrCodeImageData,
    this.acquiredDate,
    this.fundCluster,
  });

  final String id;
  final int productNameId;
  final int productDescriptionId;
  final String? specification;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final String encryptedId;
  final String qrCodeImageData;
  final DateTime? acquiredDate;
  final FundCluster? fundCluster;
}
