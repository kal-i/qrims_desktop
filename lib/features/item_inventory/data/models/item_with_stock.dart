import '../../domain/entities/item_with_stock.dart';
import '../../domain/entities/product_stock.dart';
import 'item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';
import 'product_stock.dart';
import 'stock.dart';

class ItemWithStockModel extends ItemWithStockEntity {
  const ItemWithStockModel({
    required super.productStockEntity,
    required super.itemEntity,
    required super.manufacturerBrandEntity,
    required super.modelEntity,
  });

  factory ItemWithStockModel.fromJson(Map<String, dynamic> json) {
    return ItemWithStockModel(
      productStockEntity: ProductStockModel.fromJson(json['product_stock']),
      itemEntity: ItemModel.fromJson(json['item']),
      manufacturerBrandEntity:
          ManufacturerBrandModel.fromJson(json['manufacturer_brand']),
      modelEntity: Model.fromJson(json['model']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_stock': (productStockEntity as ProductStockModel).toJson(),
      'item': (itemEntity as ItemModel).toJson(),
      'manufacturer_brand':
          (manufacturerBrandEntity as ManufacturerBrandModel).toJson(),
      'model': (modelEntity as Model).toJson(),
    };
  }
}
