class ReusableItemInformationEntity {
  const ReusableItemInformationEntity({
    required this.productName,
    required this.productDescription,
    required this.specifciation,
    this.quantity,
  });

  final String productName;
  final String productDescription;
  final String specifciation;
  final int? quantity;
}
