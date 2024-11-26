import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/inventory_summary.dart';
import '../repository/dashboard_repository.dart';

class GetInventorySummary implements UseCase<InventorySummaryEntity, NoParams> {
  const GetInventorySummary({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, InventorySummaryEntity>> call(NoParams params) async {
    return await dashboardRepository.getInventorySummary();
  }
}
