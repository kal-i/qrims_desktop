import '../../../../core/enums/officer_status.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/officer.dart';
import '../../domain/entities/paginated_officer_result.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/repository/officer_repository.dart';
import '../data_sources/remote/officer_remote_data_source.dart';

class OfficerRepositoryImpl implements OfficerRepository {
  const OfficerRepositoryImpl({
    required this.officerRemoteDataSource,
  });

  final OfficerRemoteDataSource officerRemoteDataSource;

  @override
  Future<Either<Failure, PaginatedOfficerResultEntity>> getOfficers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? office,
    String? sortBy,
    OfficerStatus? status,
    bool? sortAscending,
    bool? isArchived,
  }) async {
    try {
      final response = await officerRemoteDataSource.getOfficers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        office: office,
        status: status,
        sortBy: sortBy,
        sortAscending: sortAscending,
        isArchived: isArchived,
      );

      print('impl res: $response');
      return right(response);
    } on ServerException catch (e) {
      print('impl res: $e');
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, OfficerEntity>> registerOfficer({
    required String name,
    required String officeName,
    required String positionName,
  }) async {
    try {
      final response = await officerRemoteDataSource.registerOfficer(
        name: name,
        officeName: officeName,
        positionName: positionName,
      );

      return right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOfficer({
    required String id,
    String? office,
    String? position,
    String? name,
    OfficerStatus? status,
  }) async {
    try {
      final response = await officerRemoteDataSource.updateOfficer(
        id: id,
        office: office,
        position: position,
        name: name,
        status: status,
      );

      return right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateOfficerArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final response = await officerRemoteDataSource.updateOfficerArchiveStatus(
        id: id,
        isArchived: isArchived,
      );

      return right(response);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
