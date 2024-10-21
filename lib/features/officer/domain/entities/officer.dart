import 'package:equatable/equatable.dart';

class OfficerEntity extends Equatable {
  const OfficerEntity({
    required this.id,
    this.userId,
    required this.name,
    required this.positionId,
    required this.officeName,
    required this.positionName,
    this.isArchived = false,
  });

  final String id;
  final String? userId;
  final String name;
  final String positionId;
  final String officeName;
  final String positionName;
  final bool isArchived;

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    positionId,
    officeName,
    positionName,
    isArchived,
  ];
}