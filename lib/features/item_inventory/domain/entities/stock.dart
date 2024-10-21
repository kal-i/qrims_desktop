import 'package:equatable/equatable.dart';

class StockEntity extends Equatable {
  const StockEntity({
    required this.id,
    required this.productName,
    required this.description,
  });

  final String id;
  final String productName;
  final String description;

  @override
  List<Object?> get props => [
        id,
        productName,
        description,
      ];
}
