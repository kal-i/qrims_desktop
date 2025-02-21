import 'package:dio/dio.dart';

import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/inventory_custodian_slip.dart';
import '../../models/issuance.dart';
import '../../models/matched_item_with_pr.dart';
import '../../models/paginated_issuance_result.dart';
import '../../models/property_acknowledgement_receipt.dart';
import '../../models/requisition_and_issue_slip.dart';
import 'issuance_remote_data_source.dart';

class IssuanceRemoteDataSourceImpl implements IssuanceRemoteDataSource {
  const IssuanceRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<InventoryCustodianSlipModel> createICS({
    required String prId,
    required List issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'pr_id': prId,
        'issuance_items': issuanceItems,
        "receiving_officer_office": receivingOfficerOffice,
        "receiving_officer_position": receivingOfficerPosition,
        "receiving_officer_name": receivingOfficerName,
        "sending_officer_office": sendingOfficerOffice,
        "sending_officer_position": sendingOfficerPosition,
        "sending_officer_name": sendingOfficerName,
      };

      final response = await httpService.post(
        endpoint: icsEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return InventoryCustodianSlipModel.fromJson(response.data['ics']);
      } else {
        throw const ServerException('ICS registration failed.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PropertyAcknowledgementReceiptModel> createPAR({
    required String prId,
    String? propertyNumber,
    required List issuanceItems,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String sendingOfficerOffice,
    required String sendingOfficerPosition,
    required String sendingOfficerName,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'pr_id': prId,
        if (propertyNumber != null && propertyNumber.isNotEmpty)
          'property_number': propertyNumber,
        'issuance_items': issuanceItems,
        "receiving_officer_office": receivingOfficerOffice,
        "receiving_officer_position": receivingOfficerPosition,
        "receiving_officer_name": receivingOfficerName,
        "sending_officer_office": sendingOfficerOffice,
        "sending_officer_position": sendingOfficerPosition,
        "sending_officer_name": sendingOfficerName,
      };

      final response = await httpService.post(
        endpoint: parEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return PropertyAcknowledgementReceiptModel.fromJson(
            response.data['par']);
      } else {
        throw const ServerException('PAR registration failed.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RequisitionAndIssuanceSlipModel> createRIS({
    required String prId,
    required List issuanceItems,
    String? purpose,
    String? responsibilityCenterCode,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required String approvingOfficerOffice,
    required String approvingOfficerPosition,
    required String approvingOfficerName,
    required String issuingOfficerOffice,
    required String issuingOfficerPosition,
    required String issuingOfficerName,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'pr_id': prId,
        'issuance_items': issuanceItems,
        if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
        if (responsibilityCenterCode != null &&
            responsibilityCenterCode.isNotEmpty)
          'responsibility_center_code': responsibilityCenterCode,
        "receiving_officer_office": receivingOfficerOffice,
        "receiving_officer_position": receivingOfficerPosition,
        "receiving_officer_name": receivingOfficerName,
        "approving_officer_office": approvingOfficerOffice,
        "approving_officer_position": approvingOfficerPosition,
        "approving_officer_name": approvingOfficerName,
        "issuing_officer_office": issuingOfficerOffice,
        "issuing_officer_position": issuingOfficerPosition,
        "issuing_officer_name": issuingOfficerName,
      };

      final response = await httpService.post(
        endpoint: risEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return RequisitionAndIssuanceSlipModel.fromJson(response.data['ris']);
      } else {
        throw const ServerException('RIS registration failed.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaginatedIssuanceResultModel> getIssuances({
    required int page,
    required int pageSize,
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool? isArchived,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search_query': searchQuery,
        if (issueDateStart != null) 'start_date': issueDateStart,
        if (issueDateEnd != null) 'end_date': issueDateEnd,
        if (type != null && type.isNotEmpty) 'type': type,
        if (isArchived != null) 'is_archived': isArchived,
      };

      print('irmds_impl: $queryParams');

      final response = await httpService.get(
        endpoint: issuancesEP,
        queryParams: queryParams,
      );

      print('irmds_impl: ${response}');

      if (response.statusCode == 200) {
        print('irmds_impl: ${response.data}');
        return PaginatedIssuanceResultModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load issuances.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchedItemWithPrModel> matchItemWithPr({
    required String prId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'pr_id': prId,
      };

      final response = await httpService.get(
        endpoint: matchPurchaseRequestWithInventoryItemEP,
        queryParams: queryParams,
      );

      print('irds impl: $response');
      if (response.statusCode == 200) {
        return MatchedItemWithPrModel.fromJson(response.data);
      } else {
        throw const ServerException(
            'Failed to load match item with purchase request.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<IssuanceModel?> getIssuanceById({
    required String id,
  }) async {
    try {
      final response = await httpService.get(
        endpoint: '$issuancesIdEP/$id',
      );

      print('irds impl: $response');
      if (response.statusCode == 200) {
        return IssuanceModel.fromJson(response.data['issuance']);
      } else {
        throw const ServerException('Failed to load issuance.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final Map<String, dynamic> param = {
        'is_archived': isArchived,
      };

      final response = await httpService.patch(
        endpoint: '$updateIssuanceArchiveStatusEP/$id',
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
}
