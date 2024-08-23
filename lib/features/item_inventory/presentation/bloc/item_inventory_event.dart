part of 'item_inventory_bloc.dart';

sealed class ItemInventoryEvent extends Equatable {
  const ItemInventoryEvent();

  @override
  List<Object?> get props => [];
}

final class FetchItems extends ItemInventoryEvent {
  const FetchItems({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.classificationFilter,
    this.subClassFilter,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final AssetClassification? classificationFilter;
  final AssetSubClass? subClassFilter;

  @override
  List<Object?> get props => [
        page,
        pageSize,
        searchQuery,
        sortBy,
        sortAscending,
        classificationFilter,
        subClassFilter,
      ];
}

final class ItemRegister extends ItemInventoryEvent {
  const ItemRegister({
    required this.itemName,
    required this.description,
    required this.specification,
    required this.brand,
    required this.model,
    this.serialNo,
    required this.manufacturer,
    this.assetClassification,
    this.assetSubClass,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final String itemName;
  final String description;
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

  @override
  List<Object?> get props => [
        specification,
        brand,
        model,
        serialNo,
        manufacturer,
        assetClassification,
        assetSubClass,
        unit,
        quantity,
        unitCost,
        estimatedUsefulLife,
        acquiredDate,
      ];
}

final class FetchItemById extends ItemInventoryEvent {
  const FetchItemById({
    required this.id,
  });

  final int id;

  @override
  List<Object?> get props => [
        id,
      ];
}

final class ItemUpdate extends ItemInventoryEvent {
  const ItemUpdate({
    required this.id,
    this.itemName,
    this.description,
    this.specification,
    this.brand,
    this.model,
    this.serialNo,
    this.manufacturer,
    this.assetClassification,
    this.assetSubClass,
    this.unit,
    this.quantity,
    this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final int id;
  final String? itemName;
  final String? description;
  final String? specification;
  final String? brand;
  final String? model;
  final String? serialNo;
  final String? manufacturer;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit? unit;
  final int? quantity;
  final double? unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;
}
