import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  const BrandEntity({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [
    id,
    name
  ];
}