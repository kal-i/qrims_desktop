import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_reusable_item_information.dart';
import '../repository/dashboard_repository.dart';

class GetLowStockItems
    implements
        UseCase<PaginatedReusableItemInformationEntity,
            GetLowStockItemsParams> {
  const GetLowStockItems({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, PaginatedReusableItemInformationEntity>> call(
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
