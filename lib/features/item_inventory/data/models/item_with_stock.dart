import '../../domain/entities/item_with_stock.dart';
import 'item.dart';
import 'stock.dart';

class ItemWithStockModel extends ItemWithStockEntity {
  ItemWithStockModel({
    required super.itemEntity,
    super.stockEntity,
  });

  factory ItemWithStockModel.fromJson(Map<String, dynamic> json) {
    return ItemWithStockModel(
      itemEntity: ItemModel.fromJson(json['item']),
      stockEntity: json['stock'] != null ? StockModel.fromJson(json['stock']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final stockJson = stockEntity != null ? (stockEntity as StockModel).toJson() : {};

    return {
      'item': (itemEntity as ItemModel).toJson(),
      'stock': stockJson,
    };
  }
}
