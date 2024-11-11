import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/matched_item_with_pr.dart';
import '../../domain/entities/paginated_issuance_result.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/repository/issuance_repository.dart';
import '../data_sources/remote/issuance_remote_data_source.dart';

class IssuanceRepositoryImpl implements IssuanceRepository {
  const IssuanceRepositoryImpl({
    required this.issuanceRemoteDataSource,
  });

  final IssuanceRemoteDataSource issuanceRemoteDataSource;

  @override
  Future<Either<Failure, InventoryCustodianSlipEntity>> createICS({
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
      final response = await issuanceRemoteDataSource.createICS(
        prId: prId,
        issuanceItems: issuanceItems,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        sendingOfficerOffice: sendingOfficerOffice,
        sendingOfficerPosition: sendingOfficerPosition,
        sendingOfficerName: sendingOfficerName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PropertyAcknowledgementReceiptEntity>> createPAR({
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
      final response = await issuanceRemoteDataSource.createPAR(
        prId: prId,
        propertyNumber: propertyNumber,
        issuanceItems: issuanceItems,
        receivingOfficerOffice: receivingOfficerOffice,
        receivingOfficerPosition: receivingOfficerPosition,
        receivingOfficerName: receivingOfficerName,
        sendingOfficerOffice: sendingOfficerOffice,
        sendingOfficerPosition: sendingOfficerPosition,
        sendingOfficerName: sendingOfficerName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, InventoryCustodianSlipEntity?>> getIcsById(
      {required String id}) {
    // TODO: implement getIcsById
    throw UnimplementedError();
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
  Future<Either<Failure, PropertyAcknowledgementReceiptEntity?>> getParById(
      {required String id}) {
    // TODO: implement getParById
    throw UnimplementedError();
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
}
