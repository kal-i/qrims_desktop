import '../../domain/entities/categorical_inventory_data.dart';

class CategoricalInventoryDataModel extends CategoricalInventoryDataEntity {
  const CategoricalInventoryDataModel({
    required super.categoryName,
    required super.totalStock,
  });

  factory CategoricalInventoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoricalInventoryDataModel(
      categoryName: json['category_name'],
      totalStock: json['total_stock'],
    );
  }
}
