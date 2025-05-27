import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
import '../../../../core/enums/issuance_item_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/matched_item_with_pr.dart';
import '../../domain/entities/paginated_issuance_result.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
import '../../domain/repository/issuance_repository.dart';
import '../data_sources/remote/issuance_remote_data_source.dart';

class IssuanceRepositoryImpl implements IssuanceRepository {
  const IssuanceRepositoryImpl({
    required this.issuanceRemoteDataSource,
  });

  final IssuanceRemoteDataSource issuanceRemoteDataSource;

  @override
  Future<Either<Failure, InventoryCustodianSlipEntity>> createICS({
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
      final response = await issuanceRemoteDataSource.createICS(
        issuedDate: issuedDate,
        type: type,
        issuanceItems: issuanceItems,
        prId: prId,
        entityName: entityName,
        fundCluster: fundCluster,
        supplierName: supplierName,
        deliveryReceiptId: deliveryReceiptId,
        prReferenceId: prReferenceId,
        inventoryTransferReportId: inventoryTransferReportId,
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        dateAcquired: dateAcquired,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
        receivedDate: receivedDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<InventoryCustodianSlipEntity>>>
      createMultipleICS({
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
      final response = await issuanceRemoteDataSource.createMultipleICS(
        issuedDate: issuedDate,
        type: type,
        receivingOfficers: receivingOfficers,
        entityName: entityName,
        fundCluster: fundCluster,
        supplierName: supplierName,
        deliveryReceiptId: deliveryReceiptId,
        prReferenceId: prReferenceId,
        inventoryTransferReportId: inventoryTransferReportId,
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        dateAcquired: dateAcquired,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
        receivedDate: receivedDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PropertyAcknowledgementReceiptEntity>> createPAR({
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
      final response = await issuanceRemoteDataSource.createPAR(
        issuedDate: issuedDate,
        issuanceItems: issuanceItems,
        prId: prId,
        entityName: entityName,
        fundCluster: fundCluster,
        supplierName: supplierName,
        deliveryReceiptId: deliveryReceiptId,
        prReferenceId: prReferenceId,
        inventoryTransferReportId: inventoryTransferReportId,
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        dateAcquired: dateAcquired,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
        receivedDate: receivedDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PropertyAcknowledgementReceiptEntity>>>
      createMultiplePAR({
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
      final response = await issuanceRemoteDataSource.createMultiplePAR(
        issuedDate: issuedDate,
        receivingOfficers: receivingOfficers,
        entityName: entityName,
        fundCluster: fundCluster,
        supplierName: supplierName,
        deliveryReceiptId: deliveryReceiptId,
        prReferenceId: prReferenceId,
        inventoryTransferReportId: inventoryTransferReportId,
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        dateAcquired: dateAcquired,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
        receivedDate: receivedDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, RequisitionAndIssueSlipEntity>> createRIS({
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
      print('iss ris impl repo:$issuingOfficerPosition');
      final response = await issuanceRemoteDataSource.createRIS(
        issuedDate: issuedDate,
        issuanceItems: issuanceItems,
        prId: prId,
        entityName: entityName,
        fundCluster: fundCluster,
        division: division,
        responsibilityCenterCode: responsibilityCenterCode,
        officeName: officeName,
        purpose: purpose,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
        approvingOfficerOffice: approvingOfficerOffice,
        approvingOfficerPosition: approvingOfficerPosition,
        approvingOfficerName: approvingOfficerName,
        requestingOfficerOffice: requestingOfficerOffice,
        requestingOfficerPosition: requestingOfficerPosition,
        requestingOfficerName: requestingOfficerName,
        receivedDate: receivedDate,
        approvedDate: approvedDate,
        requestDate: requestDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PaginatedIssuanceResultEntity>> getIssuances({
    required int page,
    required int pageSize,
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool? isArchived,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getIssuances(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        issueDateStart: issueDateStart,
        issueDateEnd: issueDateEnd,
        type: type,
        isArchived: isArchived,
      );

      print(response.issuances);
      print(response.totalIssuanceCount);
      print('is_repo_impl: $response');
      return right(response);
    } on ServerException catch (e) {
      print('is_repo_impl: $e');
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, MatchedItemWithPrEntity>> matchItemWithPr({
    required String prId,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.matchItemWithPr(
        prId: prId,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, IssuanceEntity?>> getIssuanceById({
    required String id,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getIssuanceById(
        id: id,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final response =
          await issuanceRemoteDataSource.updateIssuanceArchiveStatus(
        id: id,
        isArchived: isArchived,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getInventorySupplyReport({
    required DateTime startDate,
    DateTime? endDate,
    FundCluster? fundCluster,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getInventorySupplyReport(
        startDate: startDate,
        endDate: endDate,
        fundCluster: fundCluster,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  }) async {
    try {
      final response =
          await issuanceRemoteDataSource.getInventoryPropertyReport(
        startDate: startDate,
        endDate: endDate,
        assetSubClass: assetSubClass,
        fundCluster: fundCluster,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getInventorySemiExpendablePropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    AssetSubClass? assetSubClass,
    FundCluster? fundCluster,
  }) async {
    try {
      final response = await issuanceRemoteDataSource
          .getInventorySemiExpendablePropertyReport(
        startDate: startDate,
        endDate: endDate,
        assetSubClass: assetSubClass,
        fundCluster: fundCluster,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      generateSemiExpendablePropertyCardData({
    required String icsId,
    required FundCluster fundCluster,
  }) async {
    try {
      final response =
          await issuanceRemoteDataSource.generateSemiExpendablePropertyCardData(
        icsId: icsId,
        fundCluster: fundCluster,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> receiveIssuance({
    required String baseIssuanceId,
    required String entity,
    required String receivingOfficerOffice,
    required String receivingOfficerPosition,
    required String receivingOfficerName,
    required DateTime receivedDate,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.receiveIssuance(
        baseIssuanceId: baseIssuanceId,
        entity: entity,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        receivedDate: receivedDate,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String?>> getAccountableOfficerId({
    required String office,
    required String position,
    required String name,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getAccountableOfficerId(
        office: office,
        position: position,
        name: name,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOfficerAccountability({
    required String officerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getOfficerAccountability(
        officerId: officerId,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> resolveIssuanceItem({
    required String baseItemId,
    required IssuanceItemStatus status,
    required DateTime date,
    String? remarks,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.resolveIssuanceItem(
        baseItemId: baseItemId,
        status: status,
        date: date,
        remarks: remarks,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
