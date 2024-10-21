import 'package:equatable/equatable.dart';

import 'product_description.dart';
import 'product_name.dart';

class ProductStockEntity extends Equatable {
  const ProductStockEntity({
    required this.productName,
    this.productDescription,
  });

  final ProductNameEntity productName;
  final ProductDescriptionEntity? productDescription;

  @override
  List<Object?> get props => [
        productName,
        productDescription,
      ];
}
