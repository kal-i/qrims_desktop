import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/inventory_summary.dart';
import '../entities/paginated_reusable_item_information.dart';
import '../entities/requests_summary.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, InventorySummaryEntity>> getInventorySummary();

  Future<Either<Failure, RequestsSummaryEntity>> getRequestsSummary();

  Future<Either<Failure, PaginatedReusableItemInformationEntity>>
      getLowStockItems({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PaginatedReusableItemInformationEntity>>
      getOutOfStockItems({
    required int page,
    required int pageSize,
  });
}
