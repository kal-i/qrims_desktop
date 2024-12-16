import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/period.dart';
import '../../../../core/error/failure.dart';
import '../entities/inventory_summary.dart';
import '../entities/paginated_item_result.dart';
import '../entities/requests_summary.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, InventorySummaryEntity>> getInventorySummary();

  Future<Either<Failure, RequestsSummaryEntity>> getMostRequestedItems({
    int? limit,
    Period? period,
  });

  Future<Either<Failure, PaginatedItemResultEntity>> getLowStockItems({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PaginatedItemResultEntity>> getOutOfStockItems({
    required int page,
    required int pageSize,
  });
}
