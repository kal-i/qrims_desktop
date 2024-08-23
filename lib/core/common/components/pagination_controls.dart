import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../config/themes/app_color.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalRecords,
    required this.pageSize,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int currentPage;
  final int totalRecords;
  final int pageSize;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalRecords / pageSize).ceil();
    final adjustedCurrentPage =
        currentPage > totalPages ? totalPages : currentPage;
    final startRecord = ((adjustedCurrentPage - 1) * pageSize) + 1;
    final endRecord = (adjustedCurrentPage * pageSize) > totalRecords
        ? totalRecords
        : (adjustedCurrentPage * pageSize);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Page size dropdown
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            icon: const Icon(
              Icons.arrow_drop_down_outlined,
              color: AppColor.accent,
              size: 12.0,
            ),
            value: pageSize,
            items: [10, 25, 50, 100]
                .map(
                  (size) => DropdownMenuItem(
                    value: size,
                    child: Text(
                      'Rows per page: $size',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.accent,
                          ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (int? newSize) {
              if (newSize != null) {
                final newTotalPages = (totalRecords / newSize).ceil();
                final newPage = adjustedCurrentPage > newTotalPages ? newTotalPages : adjustedCurrentPage;
                onPageSizeChanged(newSize);
                onPageChanged(newPage);
              }
            },
          ),
        ),

        const SizedBox(
          width: 30.0,
        ),

        // Display curr page and total rec
        Text(
          '$startRecord-$endRecord of $totalRecords',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColor.accent,
              ),
        ),

        const SizedBox(
          width: 30.0,
        ),

        // prev btn
        IconButton(
          tooltip: 'Previous Page',
          onPressed:
              adjustedCurrentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          icon: Icon(
            CupertinoIcons.arrow_left_to_line,
            color: adjustedCurrentPage > 1 ? AppColor.accent : AppColor.accentDisable2,
            size: 16.0,
          ),
        ),

        // next btn
        IconButton(
          tooltip: 'Next Page',
          onPressed: adjustedCurrentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: Icon(
            CupertinoIcons.arrow_right_to_line,
            color: adjustedCurrentPage < totalPages
                ? AppColor.accent
                : AppColor.accentDisable2,
            size: 16.0,
          ),
        ),
      ],
    );
  }
}
