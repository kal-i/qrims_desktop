import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/ics_type.dart';
import '../../../../../core/enums/issuance_item_status.dart';
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
    DateTime? issuedDate,
    IcsType? type,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? deliveryReceiptId,
    String? prReferenceId,
    String? inventoryTransferReportId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    DateTime? dateAcquired,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (issuedDate != null) 'issued_date': issuedDate.toIso8601String(),
        if (type != null) 'type': type.toString().split('.').last,
        'issuance_items': issuanceItems,
        if (prId != null && prId.isNotEmpty) 'pr_id': prId,
        if (entityName != null && entityName.isNotEmpty) 'entity': entityName,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        if (supplierName != null && supplierName.isNotEmpty)
          'supplier_name': supplierName,
        if (deliveryReceiptId != null && deliveryReceiptId.isNotEmpty)
          'delivery_receipt_id': deliveryReceiptId,
        if (prReferenceId != null && prReferenceId.isNotEmpty)
          'pr_reference_id': prReferenceId,
        if (inventoryTransferReportId != null &&
            inventoryTransferReportId.isNotEmpty)
          'inventory_transfer_report_id': inventoryTransferReportId,
        if (inspectionAndAcceptanceReportId != null &&
            inspectionAndAcceptanceReportId.isNotEmpty)
          'inspection_and_acceptance_report_id':
              inspectionAndAcceptanceReportId,
        if (contractNumber != null && contractNumber.isNotEmpty)
          'contract_number': contractNumber,
        if (purchaseOrderNumber != null && purchaseOrderNumber.isNotEmpty)
          'purchase_order_number': purchaseOrderNumber,
        if (dateAcquired != null)
          'date_acquired': dateAcquired.toIso8601String(),
        if (receivingOfficerOffice != null && receivingOfficerOffice.isNotEmpty)
          'receiving_officer_office': receivingOfficerOffice,
        if (receivingOfficerPosition != null &&
            receivingOfficerPosition.isNotEmpty)
          'receiving_officer_position': receivingOfficerPosition,
        if (receivingOfficerName != null && receivingOfficerName.isNotEmpty)
          'receiving_officer_name': receivingOfficerName,
        if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty)
          'issuing_officer_office': issuingOfficerOffice,
        if (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)
          'issuing_officer_position': issuingOfficerPosition,
        if (issuingOfficerName != null && issuingOfficerName.isNotEmpty)
          'issuing_officer_name': issuingOfficerName,
        if (receivedDate != null)
          'received_date': receivedDate.toIso8601String(),
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
  Future<List<InventoryCustodianSlipModel>> createMultipleICS({
    DateTime? issuedDate,
    IcsType? type,
    required List<dynamic> receivingOfficers,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? deliveryReceiptId,
    String? prReferenceId,
    String? inventoryTransferReportId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    DateTime? dateAcquired,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (issuedDate != null) 'issued_date': issuedDate.toIso8601String(),
        if (type != null) 'type': type.toString().split('.').last,
        'receiving_officers': receivingOfficers,
        if (entityName != null && entityName.isNotEmpty) 'entity': entityName,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        if (supplierName != null && supplierName.isNotEmpty)
          'supplier_name': supplierName,
        if (deliveryReceiptId != null && deliveryReceiptId.isNotEmpty)
          'delivery_receipt_id': deliveryReceiptId,
        if (prReferenceId != null && prReferenceId.isNotEmpty)
          'pr_reference_id': prReferenceId,
        if (inventoryTransferReportId != null &&
            inventoryTransferReportId.isNotEmpty)
          'inventory_transfer_report_id': inventoryTransferReportId,
        if (inspectionAndAcceptanceReportId != null &&
            inspectionAndAcceptanceReportId.isNotEmpty)
          'inspection_and_acceptance_report_id':
              inspectionAndAcceptanceReportId,
        if (contractNumber != null && contractNumber.isNotEmpty)
          'contract_number': contractNumber,
        if (purchaseOrderNumber != null && purchaseOrderNumber.isNotEmpty)
          'purchase_order_number': purchaseOrderNumber,
        if (dateAcquired != null)
          'date_acquired': dateAcquired.toIso8601String(),
        if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty)
          'issuing_officer_office': issuingOfficerOffice,
        if (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)
          'issuing_officer_position': issuingOfficerPosition,
        if (issuingOfficerName != null && issuingOfficerName.isNotEmpty)
          'issuing_officer_name': issuingOfficerName,
        if (receivedDate != null)
          'received_date': receivedDate.toIso8601String(),
      };

      final response = await httpService.post(
        endpoint: multiICSEP,
        params: params,
      );

      if (response.statusCode == 200) {
        // Parse the list of ICS models from the response
        final icsItems = response.data['ics_items'] as List<dynamic>;
        return icsItems
            .map((item) => InventoryCustodianSlipModel.fromJson(item))
            .toList();
      } else {
        // Try to extract informative error message from backend
        final message = response.data?['message'] ?? 'ICS registration failed.';
        throw ServerException(message);
      }
    } catch (e) {
      // If the error is a DioError with a response, extract the backend message
      if (e is DioException && e.response != null) {
        final message = e.response?.data?['message'] ?? e.toString();
        throw ServerException(message);
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PropertyAcknowledgementReceiptModel> createPAR({
    DateTime? issuedDate,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? deliveryReceiptId,
    String? prReferenceId,
    String? inventoryTransferReportId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    DateTime? dateAcquired,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (issuedDate != null) 'issued_date': issuedDate.toIso8601String(),
        'issuance_items': issuanceItems,
        if (prId != null && prId.isNotEmpty) 'pr_id': prId,
        if (entityName != null && entityName.isNotEmpty) 'entity': entityName,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        if (supplierName != null && supplierName.isNotEmpty)
          'supplier_name': supplierName,
        if (deliveryReceiptId != null && deliveryReceiptId.isNotEmpty)
          'delivery_receipt_id': deliveryReceiptId,
        if (prReferenceId != null && prReferenceId.isNotEmpty)
          'pr_reference_id': prReferenceId,
        if (inventoryTransferReportId != null &&
            inventoryTransferReportId.isNotEmpty)
          'inventory_transfer_report_id': inventoryTransferReportId,
        if (inspectionAndAcceptanceReportId != null &&
            inspectionAndAcceptanceReportId.isNotEmpty)
          'inspection_and_acceptance_report_id':
              inspectionAndAcceptanceReportId,
        if (contractNumber != null && contractNumber.isNotEmpty)
          'contract_number': contractNumber,
        if (purchaseOrderNumber != null && purchaseOrderNumber.isNotEmpty)
          'purchase_order_number': purchaseOrderNumber,
        if (dateAcquired != null)
          'date_acquired': dateAcquired.toIso8601String(),
        if (receivingOfficerOffice != null && receivingOfficerOffice.isNotEmpty)
          'receiving_officer_office': receivingOfficerOffice,
        if (receivingOfficerPosition != null &&
            receivingOfficerPosition.isNotEmpty)
          'receiving_officer_position': receivingOfficerPosition,
        if (receivingOfficerName != null && receivingOfficerName.isNotEmpty)
          'receiving_officer_name': receivingOfficerName,
        if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty)
          'issuing_officer_office': issuingOfficerOffice,
        if (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)
          'issuing_officer_position': issuingOfficerPosition,
        if (issuingOfficerName != null && issuingOfficerName.isNotEmpty)
          'issuing_officer_name': issuingOfficerName,
        if (receivedDate != null)
          'received_date': receivedDate.toIso8601String(),
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
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == HttpStatus.badRequest ||
            e.response?.statusCode == HttpStatus.internalServerError) {
          // Pass through the specific error message about which serial number exists
          throw ServerException(errorMessage);
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PropertyAcknowledgementReceiptModel>> createMultiplePAR({
    DateTime? issuedDate,
    required List<dynamic> receivingOfficers,
    String? entityName,
    FundCluster? fundCluster,
    String? supplierName,
    String? deliveryReceiptId,
    String? prReferenceId,
    String? inventoryTransferReportId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    DateTime? dateAcquired,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    DateTime? receivedDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        if (issuedDate != null) 'issued_date': issuedDate.toIso8601String(),
        'receiving_officers': receivingOfficers,
        if (entityName != null && entityName.isNotEmpty) 'entity': entityName,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        if (supplierName != null && supplierName.isNotEmpty)
          'supplier_name': supplierName,
        if (deliveryReceiptId != null && deliveryReceiptId.isNotEmpty)
          'delivery_receipt_id': deliveryReceiptId,
        if (prReferenceId != null && prReferenceId.isNotEmpty)
          'pr_reference_id': prReferenceId,
        if (inventoryTransferReportId != null &&
            inventoryTransferReportId.isNotEmpty)
          'inventory_transfer_report_id': inventoryTransferReportId,
        if (inspectionAndAcceptanceReportId != null &&
            inspectionAndAcceptanceReportId.isNotEmpty)
          'inspection_and_acceptance_report_id':
              inspectionAndAcceptanceReportId,
        if (contractNumber != null && contractNumber.isNotEmpty)
          'contract_number': contractNumber,
        if (purchaseOrderNumber != null && purchaseOrderNumber.isNotEmpty)
          'purchase_order_number': purchaseOrderNumber,
        if (dateAcquired != null)
          'date_acquired': dateAcquired.toIso8601String(),
        if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty)
          'issuing_officer_office': issuingOfficerOffice,
        if (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)
          'issuing_officer_position': issuingOfficerPosition,
        if (issuingOfficerName != null && issuingOfficerName.isNotEmpty)
          'issuing_officer_name': issuingOfficerName,
        if (receivedDate != null)
          'received_date': receivedDate.toIso8601String(),
      };

      final response = await httpService.post(
        endpoint: multiPAREP,
        params: params,
      );

      if (response.statusCode == 200) {
        // Parse the list of ICS models from the response
        final parItems = response.data['par_items'] as List<dynamic>;
        return parItems
            .map((item) => PropertyAcknowledgementReceiptModel.fromJson(item))
            .toList();
      } else {
        // Try to extract informative error message from backend
        final message = response.data?['message'] ?? 'PAR registration failed.';
        throw ServerException(message);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RequisitionAndIssuanceSlipModel> createRIS({
    DateTime? issuedDate,
    required List<dynamic> issuanceItems,
    String? prId,
    String? entityName,
    FundCluster? fundCluster,
    String? division,
    String? responsibilityCenterCode,
    String? officeName,
    String? purpose,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
    String? approvingOfficerOffice,
    String? approvingOfficerPosition,
    String? approvingOfficerName,
    String? requestingOfficerOffice,
    String? requestingOfficerPosition,
    String? requestingOfficerName,
    DateTime? receivedDate,
    DateTime? approvedDate,
    DateTime? requestDate,
  }) async {
    try {
      print('iss ds impl: $issuingOfficerPosition');
      final Map<String, dynamic> params = {
        if (issuedDate != null) 'issued_date': issuedDate.toIso8601String(),
        'issuance_items': issuanceItems,
        if (prId != null && prId.isNotEmpty) 'pr_id': prId,
        if (entityName != null && entityName.isNotEmpty) 'entity': entityName,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        if (division != null && division.isNotEmpty) 'division': division,
        if (responsibilityCenterCode != null &&
            responsibilityCenterCode.isNotEmpty)
          'responsibility_center_code': responsibilityCenterCode,
        if (officeName != null && officeName.isNotEmpty)
          'office_name': officeName,
        if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
        if (receivingOfficerOffice != null && receivingOfficerOffice.isNotEmpty)
          'receiving_officer_office': receivingOfficerOffice,
        if (receivingOfficerPosition != null &&
            receivingOfficerPosition.isNotEmpty)
          'receiving_officer_position': receivingOfficerPosition,
        if (receivingOfficerName != null && receivingOfficerName.isNotEmpty)
          'receiving_officer_name': receivingOfficerName,
        if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty)
          'issuing_officer_office': issuingOfficerOffice,
        if (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)
          'issuing_officer_position': issuingOfficerPosition,
        if (issuingOfficerName != null && issuingOfficerName.isNotEmpty)
          'issuing_officer_name': issuingOfficerName,
        if (approvingOfficerOffice != null && approvingOfficerOffice.isNotEmpty)
          'approving_officer_office': approvingOfficerOffice,
        if (approvingOfficerPosition != null &&
            approvingOfficerPosition.isNotEmpty)
          'approving_officer_position': approvingOfficerPosition,
        if (approvingOfficerName != null && approvingOfficerName.isNotEmpty)
          'approving_officer_name': approvingOfficerName,
        if (requestingOfficerOffice != null &&
            requestingOfficerOffice.isNotEmpty)
          'requesting_officer_office': requestingOfficerOffice,
        if (requestingOfficerPosition != null &&
            requestingOfficerPosition.isNotEmpty)
          'requesting_officer_position': requestingOfficerPosition,
        if (requestingOfficerName != null && requestingOfficerName.isNotEmpty)
          'requesting_officer_name': requestingOfficerName,
        if (receivedDate != null)
          'received_date': receivedDate.toIso8601String(),
        if (approvedDate != null)
          'approved_date': approvedDate.toIso8601String(),
        if (requestDate != null) 'request_date': requestDate.toIso8601String(),
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

  @override
  Future<List<Map<String, dynamic>>> getInventorySupplyReport({
    required DateTime startDate,
    DateTime? endDate,
    FundCluster? fundCluster,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
      };

      final response = await httpService.get(
        endpoint: inventorySupplyReportEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['inventory_supply']);
      } else {
        throw ServerException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (assetSubClass != null)
          'asset_sub_class': assetSubClass.toString().split('.').last,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
      };

      final response = await httpService.get(
        endpoint: inventoryPropertyReportEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['inventory_property']);
      } else {
        throw ServerException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInventorySemiExpendablePropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (assetSubClass != null)
          'asset_sub_class': assetSubClass.toString().split('.').last,
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
      };

      final response = await httpService.get(
        endpoint: inventorySemiExpendablePropertyReportEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['inventory_semi_expendable_property']);
      } else {
        throw ServerException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateSemiExpendablePropertyCardData({
    required String icsId,
    required FundCluster fundCluster,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'ics_id': icsId,
        'fund_cluster': fundCluster.toString().split('.').last,
      };

      final response = await httpService.get(
        endpoint: semiExpendablePropertyCardDataEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            response.data['semi_expendable_property_card_data']);
      } else {
        throw ServerException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> receiveIssuance({
    required String baseIssuanceId,
    required String entity,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required DateTime receivedDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'entity': entity,
        'receiving_officer_office': receivingOfficerOffice,
        'receiving_officer_position': receivingOfficerPosition,
        'receiving_officer_name': receivingOfficerName,
        'received_date': receivedDate.toIso8601String(),
      };

      final response = await httpService.patch(
        endpoint: '$issuancesIdEP/$baseIssuanceId',
        params: params,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw const ServerException('Failed to receive issuance.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String?> getAccountableOfficerId({
    required String office,
    required String position,
    required String name,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'office': office,
        'position': position,
        'name': name,
      };

      final response = await httpService.get(
        endpoint: officerLookUpEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return response.data['officer_id'];
      } else {
        final message = response.data?['error'] ?? 'Officer not found.';
        throw ServerException(message);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      final message =
          errorData?['error'] ?? e.message ?? 'Unknown error occurred.';

      print('❌ DioException: $message (Status code: $statusCode)');

      throw ServerException(message);
    } catch (e) {
      print('❌ Unknown error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOfficerAccountability({
    required String officerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'officer_id': officerId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await httpService.get(
        endpoint: '$officerAccountabilityEP/$officerId',
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
          response.data,
        );
      } else {
        throw ServerException('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> resolveIssuanceItem({
    required String baseItemId,
    required IssuanceItemStatus status,
    required DateTime date,
    String? remarks,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'status': status.toString().split('.').last,
        'date': date.toIso8601String(),
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final response = await httpService.patch(
        endpoint: '$resolveIssuanceItemEP/$baseItemId',
        params: params,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw const ServerException('Failed to resolve issuance item.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
