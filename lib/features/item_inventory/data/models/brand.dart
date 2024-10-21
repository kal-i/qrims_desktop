import '../../domain/entities/brand.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['brand_id'] as String? ?? '',
      name: json['brand_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': id,
      'brand_name': name,
    };
  }
}
