import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/base_item.dart';
import '../repository/item_inventory_repository.dart';

class GetItemById implements UseCase<BaseItemEntity?, String> {
  const GetItemById({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, BaseItemEntity?>> call(String param) async {
    return await itemInventoryRepository.getItemById(
      id: param,
    );
  }
}
