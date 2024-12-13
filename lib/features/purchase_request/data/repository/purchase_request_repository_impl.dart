import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/enums/unit.dart' as unit;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/paginated_purchase_request_result.dart';
import '../../domain/entities/purchase_request.dart';
import '../../domain/entities/purchase_request_with_notification_trail.dart';
import '../../domain/repository/purchase_request_repository.dart';
import '../data_sources/remote/purchase_request_remote_data_source.dart';

class PurchaseRequestRepositoryImpl implements PurchaseRequestRepository {
  const PurchaseRequestRepositoryImpl({
    required this.purchaseRequestRemoteDataSource,
  });

  final PurchaseRequestRemoteDataSource purchaseRequestRemoteDataSource;

  @override
  Future<Either<Failure, PaginatedPurchaseRequestResultEntity>>
      getPurchaseRequests({
    required int page,
    required int pageSize,
    String? prId,
    double? unitCost,
    DateTime? startDate,
    DateTime? endDate,
    PurchaseRequestStatus? prStatus,
    bool? isArchived,
  }) async {
    try {
      final response =
          await purchaseRequestRemoteDataSource.getPurchaseRequests(
        page: page,
        pageSize: pageSize,
        prId: prId,
        unitCost: unitCost,
        startDate: startDate,
        endDate: endDate,
        prStatus: prStatus,
        isArchived: isArchived,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PurchaseRequestEntity>> registerPurchaseRequest({
    required String entityName,
    required FundCluster fundCluster,
    required String officeName,
    required DateTime date,
    required String productName,
    required String productDescription,
    required unit.Unit unit,
    required int quantity,
    required double unitCost,
    required String purpose,
    required String requestingOfficerOffice,
    required String requestingOfficerPosition,
    required String requestingOfficerName,
    required String approvingOfficerOffice,
    required String approvingOfficerPosition,
    required String approvingOfficerName,
  }) async {
    try {
      final response =
          await purchaseRequestRemoteDataSource.registerPurchaseRequest(
        entityName: entityName,
        fundCluster: fundCluster,
        officeName: officeName,
        date: date,
        productName: productName,
        productDescription: productDescription,
        unit: unit,
        quantity: quantity,
        unitCost: unitCost,
        purpose: purpose,
        requestingOfficerOffice: requestingOfficerOffice,
        requestingOfficerPosition: requestingOfficerPosition,
        requestingOfficerName: requestingOfficerName,
        approvingOfficerOffice: approvingOfficerOffice,
        approvingOfficerPosition: approvingOfficerPosition,
        approvingOfficerName: approvingOfficerName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePurchaseRequestStatus({
    required String id,
    required PurchaseRequestStatus status,
  }) async {
    try {
      final response =
          await purchaseRequestRemoteDataSource.updatePurchaseRequestStatus(
        id: id,
        status: status,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PurchaseRequestWithNotificationTrailEntity>>
  getPurchaseRequestById({
    required String prId,
  }) async {
    try {
      final response =
      await purchaseRequestRemoteDataSource.getPurchaseRequestById(
        prId: prId,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
