part of 'item_inventory_bloc.dart';

sealed class ItemInventoryState extends Equatable {
  const ItemInventoryState();

  @override
  List<Object?> get props => [];
}

final class ItemsInitial extends ItemInventoryState {}

final class ItemsLoading extends ItemInventoryState {}

final class ItemsLoaded extends ItemInventoryState {
  const ItemsLoaded({
    required this.items,
    required this.totalItemCount,
    required this.suppliesCount,
    required this.inventoryCount,
    required this.outOfStockCount,
  });

  final List<BaseItemEntity> items;
  final int totalItemCount;
  final int suppliesCount;
  final int inventoryCount;
  final int outOfStockCount;
}

final class ItemsError extends ItemInventoryState {
  const ItemsError({
    required this.message,
  });

  final String message;
}

final class SupplyItemRegistered extends ItemInventoryState {
  const SupplyItemRegistered({
    required this.itemEntity,
  });

  final BaseItemEntity itemEntity;
}

final class InventoryItemRegistered extends ItemInventoryState {
  const InventoryItemRegistered({
    required this.itemEntities,
  });

  final List<BaseItemEntity> itemEntities;
}

final class ItemFetched extends ItemInventoryState {
  const ItemFetched({
    required this.item,
  });

  final BaseItemEntity item;
}

final class ItemUpdated extends ItemInventoryState {
  const ItemUpdated({
    required this.isSuccessful,
  });

  final bool isSuccessful;

  @override
  List<Object?> get props => [
        isSuccessful,
      ];
}
