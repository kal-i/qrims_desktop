import '../../../../core/enums/period.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/inventory_summary.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/entities/paginated_item_result.dart';
import '../../domain/entities/requests_summary.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../data_sources/remote/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({
    required this.dashboardRemoteDataSource,
  });

  final DashboardRemoteDataSource dashboardRemoteDataSource;
  @override
  Future<Either<Failure, InventorySummaryEntity>> getInventorySummary() async {
    try {
      final response = await dashboardRemoteDataSource.getInventorySummary();

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, RequestsSummaryEntity>> getMostRequestedItems({
    int? limit,
    Period? period,
  }) async {
    try {
      final response = await dashboardRemoteDataSource.getMostRequestedItems(
        limit: limit,
        period: period,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaginatedItemResultEntity>> getLowStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await dashboardRemoteDataSource.getLowStockItems(
        page: page,
        pageSize: pageSize,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaginatedItemResultEntity>> getOutOfStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await dashboardRemoteDataSource.getOutOfStockItems(
        page: page,
        pageSize: pageSize,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
