class PaginatedItemNameEntity {
  const PaginatedItemNameEntity({
    required this.itemNames,
    required this.totalItemCount,
  });

  final List<String> itemNames;
  final int totalItemCount;
}