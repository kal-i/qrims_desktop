import '../../../../core/enums/role.dart';
import 'user.dart';

class SupplyDepartmentEmployeeEntity extends UserEntity {
  const SupplyDepartmentEmployeeEntity({
    required super.id,
    required super.name,
    required super.email,
    required super.password,
    required super.createdAt,
    super.updatedAt,
    super.authStatus,
    super.isArchived,
    super.otp,
    super.otpExpiry,
    super.profileImage,
    required this.employeeId,
    required this.role,
  });

  final String employeeId;
  final Role role;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        password,
        createdAt,
        updatedAt,
        authStatus,
        isArchived,
        otp,
        otpExpiry,
        profileImage,
        employeeId,
        role,
      ];
}
