class ReusableItemInformationEntity {
  const ReusableItemInformationEntity({
    required this.productName,
    required this.productDescription,
    this.specification,
    this.quantity,
  });

  final String productName;
  final String productDescription;
  final String? specification;
  final int? quantity;
}
