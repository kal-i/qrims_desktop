import 'item.dart';

class Pagination {
  const Pagination({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    required this.items,
  });

  final int? lastVisiblePage;
  final bool? hasNextPage;
  final int? currentPage;
  final Item? items;
}
