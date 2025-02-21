import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/requests_summary.dart';
import '../repository/dashboard_repository.dart';

class GetRequestsSummary implements UseCase<RequestsSummaryEntity, NoParams> {
  const GetRequestsSummary({
    required this.dashboardRepository,
  });

  final DashboardRepository dashboardRepository;

  @override
  Future<Either<Failure, RequestsSummaryEntity>> call(NoParams params) async {
    return await dashboardRepository.getRequestsSummary();
  }
}
