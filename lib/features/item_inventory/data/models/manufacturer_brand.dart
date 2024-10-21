import '../../domain/entities/brand.dart';
import '../../domain/entities/manufacturer.dart';
import '../../domain/entities/manufacturer_brand.dart';
import 'brand.dart';
import 'manufacturer.dart';

class ManufacturerBrandModel extends ManufacturerBrandEntity {
  const ManufacturerBrandModel({
    required super.manufacturer,
    required super.brand,
  });

  factory ManufacturerBrandModel.fromJson(Map<String, dynamic> json) {
    return ManufacturerBrandModel(
      manufacturer: ManufacturerModel.fromJson(json['manufacturer']),
      brand: BrandModel.fromJson(json['brand']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': (manufacturer as ManufacturerModel).toJson(),
      'brand': (brand as BrandModel).toJson(),
    };
  }
}