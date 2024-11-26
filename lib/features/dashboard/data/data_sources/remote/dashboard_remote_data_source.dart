import '../../../../../core/enums/period.dart';
import '../../models/inventory_summary.dart';
import '../../models/most_requested_items.dart';

abstract interface class DashboardRemoteDataSource {
  Future<InventorySummaryModel> getInventorySummary();

  Future<MostRequestedItemsModel> getMostRequestedItems({
    int? limit,
    Period? period,
  });
}