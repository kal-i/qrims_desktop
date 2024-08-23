import 'package:equatable/equatable.dart';

enum AssetClassification {
  buildingsAndStructure,
  machineryAndEquipment,
  transportation,
  furnitureFixturesAndBooks,
  unknown,
}

enum AssetSubClass {
  schoolBuildings,
  machinery,
  office,
  informationAndCommunicationTechnologyEquipment,
  medical,
  dental,
  sports,
  motorVehicles,
  furnitureAndBooks,
  unknown,
}

enum Unit {
  unit,
  set,
  pack,
  liter,
  undetermined,
}

class Stock {
  const Stock({
    required this.id,
    required this.productName,
    required this.description,
  });

  final int id;
  final String productName;
  final String description;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
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
}

class Item extends Equatable {
  const Item({
    required this.id,
    required this.specification,
    required this.brand,
    required this.model,
    this.serialNo = '',
    required this.manufacturer,
    this.assetClassification = AssetClassification.unknown,
    this.assetSubClass = AssetSubClass.unknown,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife = 0,
    this.acquiredDate,
    required this.encryptedId,
    required this.qrCodeImageData,
    this.stockId,
  });

  final int id;
  final String specification;
  final String brand;
  final String model;
  final String? serialNo;
  final String manufacturer;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
  final String encryptedId;
  final String qrCodeImageData;
  final int? stockId;

  factory Item.fromJson(Map<String, dynamic> json) {
    final assetClassificationString = json['asset_classification'] as String?;
    final assetSubClassString = json['asset_sub_class'] as String?;
    final unitString = json['unit'] as String;

    final assetClassification = assetClassificationString != null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == assetClassificationString,
            orElse: () => AssetClassification.unknown,
          )
        : AssetClassification.unknown;

    final assetSubClass = assetSubClassString != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == assetSubClassString,
            orElse: () => AssetSubClass.unknown,
          )
        : AssetSubClass.unknown;

    final unitValue =
        unitString.startsWith('Unit.') ? unitString.substring(5) : unitString;
    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == unitValue,
      orElse: () => Unit.undetermined,
    );

    return Item(
      id: json['item_id'] as int,
      specification: json['specification'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      serialNo: json['serial_no'] as String?,
      manufacturer: json['manufacturer'] as String,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      unit: unit,
      quantity: json['quantity'] as int,
      unitCost: json['unit_cost'] is String
          ? double.tryParse(json['unit_cost'] as String) ?? 0.0
          : json['unit_cost'] as double,
      estimatedUsefulLife: json['estimated_useful_life'] as int?,
      acquiredDate: json['acquired_date'] != null
          ? json['acquired_date'] is String
              ? DateTime.parse(json['acquired_date'] as String)
              : json['acquired_date'] as DateTime
          : null,
      encryptedId: json['encrypted_id'] as String,
      qrCodeImageData: json['qr_code_image_data'] as String,
      stockId: json['stock_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'specification': specification,
      'brand': brand,
      'model': model,
      'serial_no': serialNo,
      'manufacturer': manufacturer,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'estimated_useful_life': estimatedUsefulLife,
      'acquired_date': acquiredDate?.toIso8601String(),
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
      'stock_id': stockId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        specification,
        brand,
        serialNo,
        manufacturer,
        assetClassification,
        assetSubClass,
        unit,
        quantity,
        unitCost,
        estimatedUsefulLife,
        acquiredDate,
        encryptedId,
        qrCodeImageData,
        stockId,
      ];
}

/// Represent the data from two tables
class ItemWithStock {
  ItemWithStock({
    required this.item,
    this.stock,
  });

  final Item item;
  final Stock? stock;

  factory ItemWithStock.fromJson(Map<String, dynamic> json) {
    final stockId = json['stock_id'] as int?;
    final productName = json['product_name'] as String?;
    final description = json['description'] as String?;

    return ItemWithStock(
      item: Item.fromJson({
        'item_id': json['item_id'],
        'specification': json['specification'],
        'brand': json['brand'],
        'model': json['model'],
        'serial_no': json['serial_no'],
        'manufacturer': json['manufacturer'],
        'asset_classification': json['asset_classification'],
        'asset_sub_class': json['asset_sub_class'],
        'unit': json['unit'],
        'quantity': json['quantity'],
        'unit_cost': json['unit_cost'],
        'estimated_useful_life': json['estimated_useful_life'] as int,
        'acquired_date': json['acquired_date'] is String ? DateTime.parse(json['acquired_date'] as String) : json['acquired_date'] as DateTime,
        'encrypted_id': json['encrypted_id'],
        'qr_code_image_data': json['qr_code_image_data'],
        'stock_id': stockId,
      }),
      stock: // stockId != null - my bad here, we will also create a stock if ever the pname and desc is provided
          productName != null && description != null ? Stock.fromJson({
              'id': json['stock_id'],
              'product_name': productName,
              'description': description,
            })
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final stockJson = stock != null
        ? stock?.toJson()
    // {
    //         'stock_id': stock!.id,
    //         'product_name': stock!.productName,
    //         'description': stock!.description,
    //       }
        : {};

    return {
      'item': item.toJson(),
      'stock': stockJson,
    };
  }
}
