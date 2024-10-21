import 'package:equatable/equatable.dart';

class ModelEntity extends Equatable {
  const ModelEntity({
    required this.id,
    required this.stockId,
    required this.brandId,
    required this.modelName,
  });

  final String id;
  final String stockId;
  final String brandId;
  final String modelName;

  @override
  List<Object?> get props => [
    id,
    stockId,
    brandId,
    modelName,
  ];
}