import 'package:equatable/equatable.dart';

import 'brand.dart';
import 'manufacturer.dart';

class ManufacturerBrandEntity extends Equatable {
  const ManufacturerBrandEntity({
    required this.manufacturer,
    required this.brand,
  });

  final ManufacturerEntity manufacturer;
  final BrandEntity brand;

  @override
  List<Object?> get props => [
    manufacturer,
    brand,
      ];
}
