import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_reusable_item_information.dart';
import '../repository/dashboard_repository.dart';

class GetOutOfStockItems
    implements
        UseCase<PaginatedReusableItemInformationEntity,
            GetOutOfStockItemsParams> {
  const GetOutOfStockItems({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, PaginatedReusableItemInformationEntity>> call(
      GetOutOfStockItemsParams params) async {
    return await dashboardRepository.getOutOfStockItems(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetOutOfStockItemsParams {
  const GetOutOfStockItemsParams({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}
