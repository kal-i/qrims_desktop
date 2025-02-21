import '../../models/inventory_summary.dart';
import '../../models/paginated_reusable_item_information.dart';
import '../../models/requests_summary.dart';

abstract interface class DashboardRemoteDataSource {
  Future<InventorySummaryModel> getInventorySummary();

  Future<RequestsSummaryModel> getRequestsSummary();

  Future<PaginatedReusableItemInformationModel> getLowStockItems({
    required int page,
    required int pageSize,
  });

  Future<PaginatedReusableItemInformationModel> getOutOfStockItems({
    required int page,
    required int pageSize,
  });
}
