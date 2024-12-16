import '../../../../../core/enums/period.dart';
import '../../models/inventory_summary.dart';
import '../../models/paginated_item_result.dart';
import '../../models/requests_summary.dart';

abstract interface class DashboardRemoteDataSource {
  Future<InventorySummaryModel> getInventorySummary();

  Future<RequestsSummaryModel> getMostRequestedItems({
    int? limit,
    Period? period,
  });

  Future<PaginatedItemResultModel> getLowStockItems({
    required int page,
    required int pageSize,
  });

  Future<PaginatedItemResultModel> getOutOfStockItems({
    required int page,
    required int pageSize,
  });
}
