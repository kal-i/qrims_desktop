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
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  final List<BaseItemEntity> items;
  final int totalItemCount;
  final int inStockCount;
  final int lowStockCount;
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

final class EquipmentItemRegistered extends ItemInventoryState {
  const EquipmentItemRegistered({
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
