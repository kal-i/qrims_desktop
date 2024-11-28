import '../../../../../core/enums/period.dart';
import '../../models/inventory_summary.dart';
import '../../models/most_requested_items.dart';
import '../../models/paginated_item_result.dart';

abstract interface class DashboardRemoteDataSource {
  Future<InventorySummaryModel> getInventorySummary();

  Future<MostRequestedItemsModel> getMostRequestedItems({
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
