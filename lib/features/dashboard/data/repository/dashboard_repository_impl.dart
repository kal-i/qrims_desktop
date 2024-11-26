import '../../../../core/enums/period.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/inventory_summary.dart';
import '../../domain/entities/most_requested_items.dart';
import 'package:fpdart/src/either.dart';

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
  Future<Either<Failure, MostRequestedItemsEntity>> getMostRequestedItems({
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
}
