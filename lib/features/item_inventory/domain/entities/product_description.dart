import 'package:equatable/equatable.dart';

class ProductDescriptionEntity extends Equatable {
  const ProductDescriptionEntity({
    required this.id,
    this.description,
  });

  final String id;
  final String? description;

  @override
  List<Object?> get props => [
        id,
        description,
      ];
}
