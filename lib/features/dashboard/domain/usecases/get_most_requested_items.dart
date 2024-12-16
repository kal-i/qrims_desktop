import 'package:fpdart/src/either.dart';

import '../../../../core/enums/period.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/requests_summary.dart';
import '../repository/dashboard_repository.dart';

class GetMostRequestedItems
    implements UseCase<RequestsSummaryEntity, GetMostRequestedItemsParams> {
  const GetMostRequestedItems({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, RequestsSummaryEntity>> call(
      GetMostRequestedItemsParams params) async {
    return await dashboardRepository.getMostRequestedItems(
      limit: params.limit,
      period: params.period,
    );
  }
}

class GetMostRequestedItemsParams {
  const GetMostRequestedItemsParams({
    this.limit,
    this.period,
  });

  final int? limit;
  final Period? period;
}
