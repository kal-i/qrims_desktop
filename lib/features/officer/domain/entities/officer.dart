import 'package:equatable/equatable.dart';

import '../../../../core/enums/officer_status.dart';
import 'position_history.dart';

class OfficerEntity extends Equatable {
  const OfficerEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.positionId,
    required this.officeName,
    required this.positionName,
    this.status = OfficerStatus.active,
    required this.positionHistory,
    this.isArchived = false,
  });

  final String id;
  final String? userId;
  final String name;
  final String positionId;
  final String officeName;
  final String positionName;
  final OfficerStatus status;
  final List<PositionHistoryEntity> positionHistory;
  final bool isArchived;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        positionId,
        officeName,
        positionName,
        status,
        positionHistory,
        isArchived,
      ];
}
