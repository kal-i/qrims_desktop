import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/unit.dart';
import '../../domain/entities/base_item.dart';
import '../../domain/usecases/get_item_by_id.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/register_equipment_item.dart';
import '../../domain/usecases/register_supply_item.dart';
import '../../domain/usecases/update_item.dart';

part 'item_inventory_event.dart';
part 'item_inventory_state.dart';

class ItemInventoryBloc extends Bloc<ItemInventoryEvent, ItemInventoryState> {
  ItemInventoryBloc({
    required GetItems getItems,
    required RegisterSupplyItem registerSupplyItem,
    required RegisterEquipmentItem registerEquipmentItem,
    required GetItemById getItemById,
    required UpdateItem updateItem,
  })  : _getItems = getItems,
        _registerSupplyItem = registerSupplyItem,
        _registerEquipmentItem = registerEquipmentItem,
        _getItemById = getItemById,
        _updateItem = updateItem,
        super(ItemsInitial()) {
    on<FetchItems>(_onFetchItems);
    on<SupplyItemRegister>(_onRegisterSupplyItem);
    on<EquipmentItemRegister>(_onRegisterEquipmentItem);
    on<FetchItemById>(_onFetchItemById);
    on<ItemUpdate>(_onUpdateItem);
  }

  final GetItems _getItems;
  final RegisterSupplyItem _registerSupplyItem;
  final RegisterEquipmentItem _registerEquipmentItem;
  final GetItemById _getItemById;
  final UpdateItem _updateItem;

  void _onFetchItems(FetchItems event, Emitter<ItemInventoryState> emit) async {
    emit(ItemsLoading());

    final response = await _getItems(
      GetItemsParams(
        page: event.page,
        pageSize: event.pageSize,
        searchQuery: event.searchQuery,
        filter: event.filter,
        sortBy: event.sortBy,
        sortAscending: event.sortAscending,
        manufacturerName: event.manufacturerName,
        brandName: event.brandName,
        classificationFilter: event.classificationFilter,
        subClassFilter: event.subClassFilter,
      ),
    );

    response.fold(
      (l) => emit(
        ItemsError(message: l.message),
      ),
      (r) => emit(
        ItemsLoaded(
          items: r.items,
          totalItemCount: r.totalItemCount,
          inStockCount: r.suppliesCount,
          lowStockCount: r.equipmentCount,
          outOfStockCount: r.outOfStockCount,
        ),
      ),
    );
  }

  void _onRegisterSupplyItem(
    SupplyItemRegister event,
    Emitter<ItemInventoryState> emit,
  ) async {
    emit(ItemsLoading());

    final response = await _registerSupplyItem(
      RegisterSupplyItemParams(
        itemName: event.itemName,
        description: event.description,
        specification: event.specification,
        unit: event.unit,
        quantity: event.quantity,
      ),
    );

    response.fold(
      (l) => emit(
        ItemsError(
          message: l.message,
        ),
      ),
      (r) => emit(
        SupplyItemRegistered(
          itemEntity: r,
        ),
      ),
    );
  }

  void _onRegisterEquipmentItem(
    EquipmentItemRegister event,
    Emitter<ItemInventoryState> emit,
  ) async {
    emit(ItemsLoading());

    final response = await _registerEquipmentItem(
      RegisterEquipmentItemParams(
        itemName: event.itemName,
        description: event.description,
        specification: event.specification,
        unit: event.unit,
        quantity: event.quantity,
        manufacturerName: event.manufacturerName,
        brandName: event.brandName,
        modelName: event.modelName,
        serialNo: event.serialNo,
        assetClassification: event.assetClassification,
        assetSubClass: event.assetSubClass,
        unitCost: event.unitCost,
        estimatedUsefulLife: event.estimatedUsefulLife,
        acquiredDate: event.acquiredDate,
      ),
    );

    response.fold(
      (l) => emit(
        ItemsError(
          message: l.message,
        ),
      ),
      (r) => emit(
        EquipmentItemRegistered(
          itemEntities: r,
        ),
      ),
    );
  }

  void _onFetchItemById(
    FetchItemById event,
    Emitter<ItemInventoryState> emit,
  ) async {
    emit(ItemsLoading());

    final response = await _getItemById(event.id);

    response.fold(
      (l) => emit(
        ItemsError(message: l.message),
      ),
      (r) => emit(
        ItemFetched(item: r!),
      ),
    );
  }

  void _onUpdateItem(
    ItemUpdate event,
    Emitter<ItemInventoryState> emit,
  ) async {
    emit(ItemsLoading());

    final response = await _updateItem(
      UpdateItemParams(
        id: event.id,
        itemName: event.itemName,
        description: event.description,
        manufacturerName: event.manufacturerName,
        brandName: event.brandName,
        modelName: event.modelName,
        serialNo: event.serialNo,
        specification: event.specification,
        assetClassification: event.assetClassification,
        assetSubClass: event.assetSubClass,
        unit: event.unit,
        quantity: event.quantity,
        unitCost: event.unitCost,
        estimatedUsefulLife: event.estimatedUsefulLife,
        acquiredDate: event.acquiredDate,
      ),
    );

    response.fold(
      (l) => emit(
        ItemsError(message: l.message),
      ),
      (r) => emit(
        ItemUpdated(isSuccessful: r),
      ),
    );
  }
}
