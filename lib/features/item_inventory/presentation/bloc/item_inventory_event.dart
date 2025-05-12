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
    this.filter,
    this.sortBy,
    this.sortAscending,
    this.manufacturerName,
    this.brandName,
    this.classificationFilter,
    this.subClassFilter,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? filter;
  final String? sortBy;
  final bool? sortAscending;
  final String? manufacturerName;
  final String? brandName;
  final AssetClassification? classificationFilter;
  final AssetSubClass? subClassFilter;

  @override
  List<Object?> get props => [
        page,
        pageSize,
        searchQuery,
        sortBy,
        sortAscending,
        manufacturerName,
        brandName,
        classificationFilter,
        subClassFilter,
      ];
}

final class SupplyItemRegister extends ItemInventoryEvent {
  const SupplyItemRegister({
    this.fundCluster,
    required this.itemName,
    required this.description,
    this.specification,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    this.acquiredDate,
  });

  final FundCluster? fundCluster;
  final String itemName;
  final String description;
  final String? specification;
  final Unit unit;
  final int quantity;
  final double unitCost;
  final DateTime? acquiredDate;

  @override
  List<Object?> get props => [
        fundCluster,
        itemName,
        description,
        specification,
        unit,
        quantity,
        unitCost,
        acquiredDate,
      ];
}

final class InventoryItemRegister extends ItemInventoryEvent {
  const InventoryItemRegister({
    this.fundCluster,
    required this.itemName,
    required this.description,
    this.specification,
    required this.unit,
    required this.quantity,
    this.manufacturerName,
    this.brandName,
    this.modelName,
    this.serialNos,
    this.assetClassification,
    this.assetSubClass,
    required this.unitCost,
    this.estimatedUsefulLife,
    this.acquiredDate,
  });

  final FundCluster? fundCluster;
  final String itemName;
  final String description;
  final String? specification;
  final Unit unit;
  final int quantity;
  final String? manufacturerName;
  final String? brandName;
  final String? modelName;
  final List<String>? serialNos;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final double unitCost;
  final int? estimatedUsefulLife;
  final DateTime? acquiredDate;

  @override
  List<Object?> get props => [
        fundCluster,
        itemName,
        description,
        manufacturerName,
        brandName,
        modelName,
        serialNos,
        specification,
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

  final String id;

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
    this.manufacturerName,
    this.brandName,
    this.modelName,
    this.serialNo,
    this.specification,
    this.assetClassification,
    this.assetSubClass,
    this.unit,
    this.quantity,
    this.unitCost,
    this.estimatedUsefulLife,
  });

  final String id;
  final String? itemName;
  final String? description;
  final String? manufacturerName;
  final String? brandName;
  final String? modelName;
  final String? serialNo;
  final String? specification;
  final AssetClassification? assetClassification;
  final AssetSubClass? assetSubClass;
  final Unit? unit;
  final int? quantity;
  final double? unitCost;
  final int? estimatedUsefulLife;
}

final class ManageStockEvent extends ItemInventoryEvent {
  const ManageStockEvent({
    required this.itemName,
    required this.description,
    required this.stockNo,
  });

  final String itemName;
  final String description;
  final int stockNo;
}
