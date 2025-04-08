import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/ics_type.dart';
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
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
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
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
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
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderNumber,
    String? receivingOfficerOffice,
    String? receivingOfficerPosition,
    String? receivingOfficerName,
    String? issuingOfficerOffice,
    String? issuingOfficerPosition,
    String? issuingOfficerName,
  }) async {
    try {
      final response = await issuanceRemoteDataSource.createPAR(
        issuedDate: issuedDate,
        issuanceItems: issuanceItems,
        prId: prId,
        entityName: entityName,
        fundCluster: fundCluster,
        supplierName: supplierName,
        inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
        contractNumber: contractNumber,
        purchaseOrderNumber: purchaseOrderNumber,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        issuingOfficerOffice: issuingOfficerOffice,
        issuingOfficerPosition: issuingOfficerPosition,
        issuingOfficerName: issuingOfficerName,
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
  }) async {
    try {
      final response = await issuanceRemoteDataSource.getInventorySupplyReport(
        startDate: startDate,
        endDate: endDate,
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
  }) async {
    try {
      final response =
          await issuanceRemoteDataSource.getInventoryPropertyReport(
        startDate: startDate,
        endDate: endDate,
        assetSubClass: assetSubClass,
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
  }) async {
    try {
      final response = await issuanceRemoteDataSource
          .getInventorySemiExpendablePropertyReport(
        startDate: startDate,
        endDate: endDate,
        assetSubClass: assetSubClass,
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
}
