import 'product_stock.dart';
import 'shareable_item_information.dart';

abstract class BaseItemEntity {
  const BaseItemEntity({
    required this.productStockEntity,
    required this.shareableItemInformationEntity,
  });

  final ProductStockEntity productStockEntity;
  final ShareableItemInformationEntity shareableItemInformationEntity;
}
