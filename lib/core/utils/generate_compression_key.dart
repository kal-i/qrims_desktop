import '../../features/item_inventory/domain/entities/inventory_item.dart';
import '../../features/item_issuance/domain/entities/issuance_item.dart';

class IssuanceItemCompressor {
  static String generateKey(IssuanceItemEntity item) {
    final info = item.itemEntity.shareableItemInformationEntity;
    final productDesc = item.itemEntity.productStockEntity.productDescription;
    final itemEntity = item.itemEntity;
    final brand = itemEntity is InventoryItemEntity
        ? itemEntity.manufacturerBrandEntity?.brand?.name ?? ''
        : '';
    final model = itemEntity is InventoryItemEntity
        ? itemEntity.modelEntity?.modelName ?? ''
        : '';
    final sn =
        itemEntity is InventoryItemEntity ? itemEntity.serialNo ?? '' : '';
    final estimatedUsefulLife = itemEntity is InventoryItemEntity
        ? itemEntity.estimatedUsefulLife
        : null;

    return [
      info.unit,
      info.unitCost.toString(),
      productDesc?.description ?? '',
      info.specification ?? '',
      brand,
      model,
      sn,
      estimatedUsefulLife?.toString() ?? '',
    ].join('|'); // use a delimiter that won't appear in actual values
  }
}
