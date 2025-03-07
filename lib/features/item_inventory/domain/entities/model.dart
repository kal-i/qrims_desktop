import 'package:equatable/equatable.dart';

class ModelEntity extends Equatable {
  const ModelEntity({
    required this.id,
    required this.productNameId,
    required this.brandId,
    required this.modelName,
  });

  final String id;
  final int productNameId;
  final String brandId;
  final String modelName;

  @override
  List<Object?> get props => [
        id,
        productNameId,
        brandId,
        modelName,
      ];
}
