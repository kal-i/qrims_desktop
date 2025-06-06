import '../../domain/entities/product_stock.dart';

import 'product_name.dart';
import 'product_description.dart';

class ProductStockModel extends ProductStockEntity {
  const ProductStockModel({
    required super.productName,
    super.productDescription,
    super.stockNo,
  });

  factory ProductStockModel.fromJson(Map<String, dynamic> json) {
    return ProductStockModel(
      productName: ProductNameModel.fromJson(json['product_name']),
      productDescription:
          ProductDescriptionModel.fromJson(json['product_description']),
      stockNo: json['stock_no'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': (productName as ProductNameModel).toJson(),
      'product_description':
          (productDescription as ProductDescriptionModel?)?.toJson(),
      'stock_no': stockNo,
    };
  }
}
