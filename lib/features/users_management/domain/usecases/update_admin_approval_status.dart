import 'package:fpdart/fpdart.dart';

import '../../../../core/enums/admin_approval_status.dart';
import '../../../../core/enums/auth_status.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/users_management_repository.dart';

class UpdateAdminApprovalStatus
    implements UseCase<bool, UpdateAdminApprovalStatusParams> {
  const UpdateAdminApprovalStatus({
    required this.usersManagementRepository,
  });

  final UsersManagementRepository usersManagementRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateAdminApprovalStatusParams params) async {
    return await usersManagementRepository.updateAdminApprovalStatus(
      id: params.id,
      adminApprovalStatus: params.adminApprovalStatus,
    );
  }
}

class UpdateAdminApprovalStatusParams {
  const UpdateAdminApprovalStatusParams({
    required this.id,
    required this.adminApprovalStatus,
  });

  final String id;
  final AdminApprovalStatus adminApprovalStatus;
}
