import 'package:dio/dio.dart';

import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/purchase_request_status.dart';
import '../../../../../core/enums/unit.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/paginated_purchase_request_result.dart';
import '../../models/purchase_request.dart';
import '../../models/purchase_request_with_notification_trail.dart';
import 'purchase_request_remote_data_source.dart';

class PurchaseRequestRemoteDataSourceImpl
    implements PurchaseRequestRemoteDataSource {
  const PurchaseRequestRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<PaginatedPurchaseRequestResultModel> getPurchaseRequests({
    required int page,
    required int pageSize,
    String? prId,
    double? unitCost,
    DateTime? date,
    PurchaseRequestStatus? prStatus,
    bool? isArchived,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (prId != null && prId.isNotEmpty) 'pr_id': prId,
        if (unitCost != null) 'unit_cost': unitCost,
        if (date != null) 'date': date,
        if (prStatus != null) 'pr_status': prStatus.toString().split('.').last,
        if (isArchived != null) 'is_archived': isArchived,
      };

      final response = await httpService.get(
        endpoint: purchaseRequestsEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedPurchaseRequestResultModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to fetch purchase requests.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PurchaseRequestModel> registerPurchaseRequest({
    required String entityName,
    required FundCluster fundCluster,
    required String officeName,
    required DateTime date,
    required String productName,
    required String productDescription,
    required Unit unit,
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
      final Map<String, dynamic> params = {
        'entity_name': entityName,
        'fund_cluster': fundCluster.toString().split('.').last,
        'office_name': officeName,
        'date': date.toIso8601String(),
        'product_name': productName,
        'product_description': productDescription,
        'unit': unit.toString().split('.').last,
        'quantity': quantity,
        'unit_cost': unitCost,
        'purpose': purpose,
        'requesting_officer_office': requestingOfficerOffice,
        'requesting_officer_position': requestingOfficerPosition,
        'requesting_officer_name': requestingOfficerName,
        'approving_officer_office': approvingOfficerOffice,
        'approving_officer_position': approvingOfficerPosition,
        'approving_officer_name': approvingOfficerName,
      };

      print('params received: $params');

      final response = await httpService.post(
        endpoint: purchaseRequestsEP,
        params: params,
      );

      print('response after req: $response');

      if (response.statusCode == 200) {
        return PurchaseRequestModel.fromJson(response.data['purchase_request']);
      } else {
        throw const ServerException('Failed to register purchase request.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updatePurchaseRequestStatus({
    required String id,
    required PurchaseRequestStatus status,
  }) async {
    try {
      final Map<String, dynamic> param = {
        'pr_status': status.toString().split('.').last,
      };

      final response = await httpService.patch(
        endpoint: '$updatePurchaseRequestStatusEP/$id',
        params: param,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PurchaseRequestWithNotificationTrailModel> getPurchaseRequestById({
    required String prId,
  }) async {
    try {
      final response = await httpService.get(
        endpoint: '$purchaseRequestIdEP/$prId',
      );

      if (response.statusCode == 200) {
        return PurchaseRequestWithNotificationTrailModel.fromJson(
            response.data);
      } else {
        throw const ServerException('Failed to fetch purchase request by id.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
