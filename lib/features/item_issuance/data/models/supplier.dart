import '../../domain/entities/supplier.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id,
    required super.name,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['supplier_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': id,
      'name': name,
    };
  }
}
