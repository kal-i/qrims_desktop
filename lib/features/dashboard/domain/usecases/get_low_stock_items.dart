import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_item_result.dart';
import '../repository/dashboard_repository.dart';

class GetLowStockItems
    implements UseCase<PaginatedItemResultEntity, GetLowStockItemsParams> {
  const GetLowStockItems({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, PaginatedItemResultEntity>> call(
      GetLowStockItemsParams params) async {
    return await dashboardRepository.getLowStockItems(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetLowStockItemsParams {
  const GetLowStockItemsParams({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}