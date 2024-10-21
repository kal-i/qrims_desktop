import 'package:equatable/equatable.dart';

import 'item.dart';
import 'manufacturer_brand.dart';
import 'model.dart';
import 'product_name.dart';
import 'product_stock.dart';
import 'stock.dart';

class ItemWithStockEntity extends Equatable {
  const ItemWithStockEntity({
    required this.productStockEntity,
    required this.itemEntity,
    required this.manufacturerBrandEntity,
    required this.modelEntity,
  });

  final ProductStockEntity productStockEntity;
  final ItemEntity itemEntity;
  final ManufacturerBrandEntity manufacturerBrandEntity;
  final ModelEntity modelEntity;

  @override
  List<Object?> get props => [
    productStockEntity,
    itemEntity,
    manufacturerBrandEntity,
    modelEntity,
  ];
}
