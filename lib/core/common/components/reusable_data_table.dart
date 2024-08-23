import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class ReusableDataTable extends StatelessWidget {
  const ReusableDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataColumn2> columns;
  final List<DataRow2> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rows.isEmpty ? 300.0 : 100 + (rows.length * 60),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: rows.isNotEmpty
          ? DataTable(
              showCheckboxColumn: false,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Theme.of(context).dividerColor,
              //     width: 1.5,
              //   ),
              //   borderRadius: BorderRadius.circular(5.0),
              // ),
              headingRowColor:
                  context.watch<ThemeBloc>().state == AppTheme.light
                      ? WidgetStateProperty.all(AppColor.lightTableColumn)
                      : WidgetStateProperty.all(AppColor.darkTableColumn),
              dataRowColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                return context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightTableRow
                    : AppColor.darkTableRow;
              }),
              headingRowHeight: 60.0,
              headingTextStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 12.0),
              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.0,
                  ),
              dividerThickness: .3,
              dataRowMaxHeight: 60.0,
              //dataRowHeight: 60.0,
              columns: columns,
              rows: rows.isEmpty ? [] : rows,
              //columnSpacing: 12,
              horizontalMargin: 12,
              //minWidth: 1280.0,
              showBottomBorder: true,
              // empty: Center(
              //   child: Container(
              //     padding: const EdgeInsets.all(10.0),
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Theme.of(context).dividerColor, width: 2.0,),
              //       borderRadius: BorderRadius.circular(10.0),
              //     ),
              //     child: Text(
              //       'No data.',
              //       style: Theme.of(context).textTheme.bodySmall,
              //     ),
              //   ),
              // ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_copy, size: 40.0,),
                const SizedBox(height: 5.0,),
                Text(
                  'No data found.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
    );
  }
}
