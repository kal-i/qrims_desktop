import '../../domain/entities/stock.dart';

class StockModel extends StockEntity {
  const StockModel({
    required super.id,
    required super.productName,
    required super.description,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['stock_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stock_id': id,
      'product_name': productName,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        super.props,
      ];
}
