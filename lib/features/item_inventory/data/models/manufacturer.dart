import '../../domain/entities/manufacturer.dart';

class ManufacturerModel extends ManufacturerEntity {
  const ManufacturerModel({
    required super.id,
    required super.name,
  });

  factory ManufacturerModel.fromJson(Map<String, dynamic> json) {
    return ManufacturerModel(
      id: json['manufacturer_id'] as String? ?? '',
      name: json['manufacturer_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer_id': id,
      'manufacturer_name': name,
    };
  }
}