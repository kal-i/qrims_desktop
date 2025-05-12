import 'package:equatable/equatable.dart';

import 'product_description.dart';
import 'product_name.dart';

class ProductStockEntity extends Equatable {
  const ProductStockEntity({
    required this.productName,
    this.productDescription,
    this.stockNo,
  });

  final ProductNameEntity productName;
  final ProductDescriptionEntity? productDescription;
  final int? stockNo;

  @override
  List<Object?> get props => [
        productName,
        productDescription,
        stockNo,
      ];
}
