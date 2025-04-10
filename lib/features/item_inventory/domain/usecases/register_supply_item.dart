import 'package:fpdart/src/either.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/unit.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/base_item.dart';
import '../repository/item_inventory_repository.dart';

class RegisterSupplyItem
    implements UseCase<BaseItemEntity, RegisterSupplyItemParams> {
  const RegisterSupplyItem({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, BaseItemEntity>> call(
    RegisterSupplyItemParams params,
  ) async {
    return await itemInventoryRepository.registerSupplyItem(
      fundCluster: params.fundCluster,
      itemName: params.itemName,
      description: params.description,
      specification: params.specification,
      unit: params.unit,
      quantity: params.quantity,
      unitCost: params.unitCost,
      acquiredDate: params.acquiredDate,
    );
  }
}

class RegisterSupplyItemParams {
  const RegisterSupplyItemParams({
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
}
