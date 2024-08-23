import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

class ReusableDataTable2 extends StatelessWidget {
  const ReusableDataTable2({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataColumn2> columns;
  final List<DataRow2> rows;

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      headingRowColor: context.watch<ThemeBloc>().state == AppTheme.light
          ? WidgetStateProperty.all(AppColor.lightTableColumn)
          : WidgetStateProperty.all(AppColor.darkTableColumn),
      dataRowColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return AppColor.darkTableRow.withOpacity(0.1);
        }
        if (states.contains(WidgetState.pressed)) {
          return AppColor.darkTableRow.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColor.darkTableRow.withOpacity(0.2);
        }
        return context.watch<ThemeBloc>().state == AppTheme.light
            ? AppColor.lightTableRow
            : AppColor.darkTableRow;
      }),
      headingRowHeight: 50.0,
      headingTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12.0),
      dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.0),
      dividerThickness: 1,
      dataRowHeight: 60.0,
      columns: columns,
      rows: rows.isEmpty ? [] : rows,
      horizontalMargin: 12,
      showBottomBorder: true,
    );
  }
}
