import 'package:api/src/issuance/models/issuance.dart';
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
  piece,
  set,
  box,
  bottle,
  pack,
  bundle,
  roll,
  pair,
  dozen,
  liter,
  milliliter,
  gallon,
  cubic_meter,
  gram,
  kilogram,
  ton,
  meter,
  centimeter,
  millimeter,
  foot,
  yard,
  batch,
  unit,
  undetermined,
}

enum InventoryActivity {
  added,
  updated,
  issued,
}

/// Represents the Product Stock
class ProductStock {
  const ProductStock({
    required this.productName,
    this.productDescription,
    this.stockNo,
  });

  final ProductName productName;
  final ProductDescription? productDescription;
  final int? stockNo;

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      productName: ProductName.fromJson({
        'product_name_id': json['product_name_id'],
        'product_name': json['product_name'],
      }),
      productDescription: ProductDescription.fromJson({
        'product_description_id': json['product_description_id'],
        'product_description': json['product_description'],
      }),
      stockNo: json['stock_no'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName.toJson(),
      'product_description': productDescription?.toJson(),
      'stock_no': stockNo,
    };
  }
}

/// Represents the Stock's name
class ProductName {
  const ProductName({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ProductName.fromJson(Map<String, dynamic> json) {
    return ProductName(
      id: json['product_name_id'] as int,
      name: json['product_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name_id': id,
      'product_name': name,
    };
  }
}

/// Represents the Stock's article
class ProductDescription {
  const ProductDescription({
    required this.id,
    this.description,
  });

  final int id;
  final String? description;

  factory ProductDescription.fromJson(Map<String, dynamic> json) {
    return ProductDescription(
      id: json['product_description_id'] as int,
      description: json['product_description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_description_id': id,
      'product_description': description,
    };
  }
}

class Manufacturer {
  const Manufacturer({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['manufacturer_id'] as String,
      name: json['manufacturer_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer_id': id,
      'manufacturer_name': name,
    };
  }
}

class Brand {
  const Brand({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['brand_id'] as String,
      name: json['brand_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': id,
      'brand_name': name,
    };
  }
}

class ManufacturerBrand {
  const ManufacturerBrand({
    required this.manufacturer,
    required this.brand,
  });

  final Manufacturer manufacturer;
  final Brand brand;

  factory ManufacturerBrand.fromJson(Map<String, dynamic> json) {
    return ManufacturerBrand(
      manufacturer: Manufacturer.fromJson({
        'manufacturer_id': json['manufacturer_id'],
        'manufacturer_name': json['manufacturer_name'],
      }),
      brand: Brand.fromJson({
        'brand_id': json['brand_id'],
        'brand_name': json['brand_name'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer.toJson(),
      'brand': brand.toJson(),
    };
  }
}

class Model {
  const Model({
    required this.id,
    required this.productNameId,
    required this.brandId,
    required this.modelName,
  });

  final String id;
  final int productNameId;
  final String brandId;
  final String modelName;

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['model_id'] as String,
      productNameId: json['product_name_id'] as int,
      brandId: json['brand_id'] as String,
      modelName: json['model_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model_id': id,
      'product_name_id': productNameId,
      'brand_id': brandId,
      'model_name': modelName,
    };
  }
}

class Item extends Equatable {
  const Item({
    required this.id,
    required this.productNameId,
    required this.productDescriptionId,
    required this.manufacturerId,
    required this.brandId,
    required this.modelId,
    this.serialNo = '',
    required this.specification,
    this.assetClassification = AssetClassification.unknown,
    this.assetSubClass = AssetSubClass.unknown,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife = 0,
    this.acquiredDate,
    required this.encryptedId,
    required this.qrCodeImageData,
  });

  final String id;
  final String productNameId;
  final String productDescriptionId;
  final String manufacturerId;
  final String brandId;
  final String modelId;
  final String? serialNo;
  final String specification;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
  final String encryptedId;
  final String qrCodeImageData;

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
      id: json['item_id'] as String,
      productNameId: json['product_name_id'] as String,
      productDescriptionId: json['product_description_id'] as String,
      manufacturerId: json['manufacturer_id'] as String,
      brandId: json['brand_id'] as String,
      modelId: json['model_id'] as String,
      serialNo: json['serial_no'] as String?,
      specification: json['specification'] as String,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'product_name_id': productNameId,
      'product_description_id': productDescriptionId,
      'manufacturer_id': manufacturerId,
      'brand_id': brandId,
      'model_id': modelId,
      'serial_no': serialNo,
      'specification': specification,
      'asset_classification': assetClassification.toString().split('.').last,
      'asset_sub_class': assetSubClass.toString().split('.').last,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'estimated_useful_life': estimatedUsefulLife,
      'acquired_date': acquiredDate?.toIso8601String(),
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
    };
  }

  @override
  List<Object?> get props => [
        id,
        productNameId,
        productDescriptionId,
        manufacturerId,
        brandId,
        modelId,
        serialNo,
        specification,
        assetClassification,
        assetSubClass,
        unit,
        quantity,
        unitCost,
        estimatedUsefulLife,
        acquiredDate,
        encryptedId,
        qrCodeImageData,
      ];
}

class ItemWithStock {
  ItemWithStock({
    required this.productStock,
    required this.item,
    required this.manufacturerBrand,
    required this.model,
  });

  final ProductStock productStock;
  final Item item;
  final ManufacturerBrand manufacturerBrand;
  final Model model;

  factory ItemWithStock.fromJson(Map<String, dynamic> json) {
    return ItemWithStock(
      productStock: ProductStock.fromJson({
        'product_name_id': json['product_name_id'],
        'product_name': json['product_name'],
        'product_description_id': json['product_description_id'],
        'product_description': json['product_description'],
      }),
      item: Item.fromJson({
        'item_id': json['item_id'],
        'product_name_id': json['product_name_id'],
        'product_description_id': json['product_description_id'],
        'manufacturer_id': json['manufacturer_id'],
        'brand_id': json['brand_id'],
        'model_id': json['model_id'],
        'serial_no': json['serial_no'],
        'specification': json['specification'],
        'asset_classification': json['asset_classification'],
        'asset_sub_class': json['asset_sub_class'],
        'unit': json['unit'],
        'quantity': json['quantity'],
        'unit_cost': json['unit_cost'],
        'estimated_useful_life': json['estimated_useful_life'] as int,
        'acquired_date': json['acquired_date'] is String
            ? DateTime.parse(json['acquired_date'] as String)
            : json['acquired_date'] as DateTime,
        'encrypted_id': json['encrypted_id'],
        'qr_code_image_data': json['qr_code_image_data'],
      }),
      manufacturerBrand: ManufacturerBrand.fromJson({
        'manufacturer_id': json['manufacturer_id'],
        'manufacturer_name': json['manufacturer_name'],
        'brand_id': json['brand_id'],
        'brand_name': json['brand_name'],
      }),
      model: Model.fromJson({
        'model_id': json['model_id'],
        'product_name_id': json['product_name_id'],
        'brand_id': json['brand_id'],
        'model_name': json['model_name'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_stock': productStock.toJson(),
      'item': item.toJson(),
      'manufacturer_brand': manufacturerBrand.toJson(),
      'model': model.toJson(),
    };
  }
}

class ShareableItemInformationModel {
  const ShareableItemInformationModel({
    required this.id,
    required this.productNameId,
    required this.productDescriptionId,
    this.specification,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.encryptedId,
    required this.qrCodeImageData,
    this.acquiredDate,
    this.fundCluster,
  });

  final String id;
  final int productNameId;
  final int productDescriptionId;
  final String? specification;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final String encryptedId;
  final String qrCodeImageData;
  final DateTime? acquiredDate;
  final FundCluster? fundCluster;

  factory ShareableItemInformationModel.fromJson(Map<String, dynamic> json) {
    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == json['unit'] as String,
      orElse: () => Unit.undetermined,
    );

    final fundCluster = (json['fund_cluster'] as String?) != null
        ? FundCluster.values.firstWhere(
            (e) => e.toString().split('.').last == json['fund_cluster'],
            orElse: () => FundCluster.unknown,
          )
        : null;

    final shareableItemInformationModel = ShareableItemInformationModel(
      id: json['base_item_id'] as String,
      productNameId: json['product_name_id'] as int,
      productDescriptionId: json['product_description_id'] as int,
      specification: json['specification'] as String?,
      unit: unit,
      quantity: json['quantity'] as int,
      unitCost: json['unit_cost'] is String
          ? double.parse(json['unit_cost'] as String)
          : json['unit_cost'] as double,
      encryptedId: json['encrypted_id'] as String,
      qrCodeImageData: json['qr_code_image_data'] as String,
      acquiredDate: json['acquired_date'] != null
          ? json['acquired_date'] is String
              ? DateTime.parse(json['acquired_date'] as String)
              : json['acquired_date'] as DateTime
          : null,
      fundCluster: fundCluster,
    );

    print('Shareable Item Information Obj converted');
    ;
    return shareableItemInformationModel;
  }

  Map<String, dynamic> toJson() {
    return {
      'base_item_id': id,
      'product_name_id': productNameId,
      'product_description_id': productDescriptionId,
      'specification': specification,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'unit_cost': unitCost,
      'encrypted_id': encryptedId,
      'qr_code_image_data': qrCodeImageData,
      'acquired_date': acquiredDate?.toIso8601String(),
      'fund_cluster': fundCluster.toString().split('.').last,
    };
  }
}

abstract class BaseItemModel {
  const BaseItemModel({
    required this.productStock,
    required this.shareableItemInformationModel,
  });

  final ProductStock productStock;
  final ShareableItemInformationModel shareableItemInformationModel;

  factory BaseItemModel.fromJson(Map<String, dynamic> json) {
    print('json received by base item mod: $json');
    if (json['supply_id'] != null) {
      print('supp received');
      return Supply.fromJson(json);
    } else {
      print('inventory received');
      return InventoryItem.fromJson(json);
    }
  }
}

class Supply extends BaseItemModel {
  const Supply({
    required this.id,
    required super.productStock,
    required super.shareableItemInformationModel,
  });

  final int id;

  factory Supply.fromJson(Map<String, dynamic> json) {
    final productStock = ProductStock.fromJson({
      'product_name_id': json['product_name_id'],
      'product_name': json['product_name'],
      'product_description_id': json['product_description_id'],
      'product_description': json['product_description'],
      'stock_no': json['stock_no'],
    });

    final shareableItemInformation = ShareableItemInformationModel.fromJson({
      'base_item_id': json['base_item_id'],
      'product_name_id': json['product_name_id'],
      'product_description_id': json['product_description_id'],
      'specification': json['specification'],
      'unit': json['unit'],
      'quantity': json['quantity'],
      'unit_cost': json['unit_cost'],
      'encrypted_id': json['encrypted_id'],
      'qr_code_image_data': json['qr_code_image_data'],
      'acquired_date': json['acquired_date'],
      'fund_cluster': json['fund_cluster'],
    });

    return Supply(
      id: json['supply_id'] as int,
      productStock: productStock,
      shareableItemInformationModel: shareableItemInformation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supply_id': id,
      'product_stock': productStock.toJson(),
      'shareable_item_information': shareableItemInformationModel.toJson(),
    };
  }
}

class InventoryItem extends BaseItemModel {
  const InventoryItem({
    required this.id,
    required super.productStock,
    required super.shareableItemInformationModel,
    this.manufacturerBrand,
    this.model,
    this.serialNo,
    this.assetClassification,
    this.assetSubClass,
    this.estimatedUsefulLife = 1,
  });

  final int id;
  final ManufacturerBrand? manufacturerBrand;
  final Model? model;
  final String? serialNo;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final int? estimatedUsefulLife;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    print('received json data by inventory model: $json');

    final assetClassification = (json['asset_classification'] as String?) !=
            null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_classification'],
            orElse: () => AssetClassification.unknown,
          )
        : null;

    final assetSubClass = (json['asset_sub_class'] as String?) != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == json['asset_sub_class'],
            orElse: () => AssetSubClass.unknown,
          )
        : null;

    final productStock = ProductStock.fromJson({
      'product_name_id': json['product_name_id'],
      'product_name': json['product_name'],
      'product_description_id': json['product_description_id'],
      'product_description': json['product_description'],
      'stock_no': json['stock_no'],
    });

    final shareableItemInformation = ShareableItemInformationModel.fromJson({
      'base_item_id': json['base_item_id'],
      'product_name_id': json['product_name_id'],
      'product_description_id': json['product_description_id'],
      'specification': json['specification'],
      'unit': json['unit'],
      'quantity': json['quantity'],
      'unit_cost': json['unit_cost'],
      'encrypted_id': json['encrypted_id'],
      'qr_code_image_data': json['qr_code_image_data'],
      'acquired_date': json['acquired_date'],
      'fund_cluster': json['fund_cluster'],
    });

    final manufacturerBrand =
        (json['manufacturer_id'] != null || json['brand_id'] != null)
            ? ManufacturerBrand.fromJson({
                'manufacturer_id': json['manufacturer_id'],
                'manufacturer_name': json['manufacturer_name'],
                'brand_id': json['brand_id'],
                'brand_name': json['brand_name'],
              })
            : null;

    final model = (json['model_id'] != null)
        ? Model.fromJson({
            'model_id': json['model_id'],
            'product_name_id': json['product_name_id'],
            'brand_id': json['brand_id'],
            'model_name': json['model_name'],
          })
        : null;

    print('almost done processing the inventory model...');

    return InventoryItem(
      id: json['inventory_id'] as int,
      productStock: productStock,
      shareableItemInformationModel: shareableItemInformation,
      manufacturerBrand: manufacturerBrand,
      model: model,
      serialNo: json['serial_no'] as String?,
      assetClassification: assetClassification,
      assetSubClass: assetSubClass,
      estimatedUsefulLife: json['estimated_useful_life'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventory_id': id,
      'product_stock': productStock.toJson(),
      'shareable_item_information': shareableItemInformationModel.toJson(),
      'manufacturer_brand': manufacturerBrand?.toJson(),
      'model': model?.toJson(),
      'serial_no': serialNo,
      'asset_classification': assetClassification?.toString().split('.').last,
      'asset_sub_class': assetSubClass?.toString().split('.').last,
      'estimated_useful_life': estimatedUsefulLife,
    };
  }
}
