import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import '../../../config/themes/bloc/theme_bloc.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/app_color.dart';

class ReusablePlutoGridView extends StatelessWidget {
  const ReusablePlutoGridView({
    super.key,
    this.onLoaded,
    required this.columns,
    required this.rows,
    this.createFooter,
  });

  final void Function(PlutoGridOnLoadedEvent)? onLoaded;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final Widget Function(PlutoGridStateManager)? createFooter;

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      onLoaded: onLoaded,
      configuration: context.watch<ThemeBloc>().state == AppTheme.light
          ? const PlutoGridConfiguration().copyWith(
              style: PlutoGridStyleConfig(
                enableColumnBorderVertical: false,
                enableCellBorderVertical: false,
                borderColor: AppColor.lightTableOutline,
                gridBackgroundColor: AppColor.lightTableColumn,
                gridBorderColor: AppColor.lightTableOutline,
                rowColor: AppColor.lightTableRow,
                columnTextStyle:
                    Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppColor.lightTableColumnText,
                        ),
                cellTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColor.lightTableRowText,
                    ),
                iconColor: AppColor.accent,
                iconSize: 0, //20.0,
                columnHeight: 50.0,
                rowHeight: 60.0,
                gridBorderRadius: BorderRadius.circular(5.0),
                menuBackgroundColor: AppColor.lightTableColumn,
              ),
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
                resizeMode: PlutoResizeMode.pushAndPull,
              ),
            )
          : PlutoGridConfiguration.dark(
              style: PlutoGridStyleConfig.dark(
                enableColumnBorderVertical: false,
                enableCellBorderVertical: false,
                borderColor: AppColor.darkTableOutline,
                gridBackgroundColor: AppColor.darkTableColumn,
                rowColor: AppColor.darkTableRow,
                gridBorderColor: AppColor.darkTableOutline,
                columnTextStyle:
                    Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppColor.darkTableColumnText,
                        ),
                cellTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColor.darkTableRowText,
                    ),
                iconColor: AppColor.accent,
                iconSize: 0, // 20.0,
                columnHeight: 50.0,
                rowHeight: 60.0,
                gridBorderRadius: BorderRadius.circular(5.0),
                menuBackgroundColor: AppColor.darkTableColumn,
              ),
              columnSize: const PlutoGridColumnSizeConfig(
                autoSizeMode: PlutoAutoSizeMode.scale,
                resizeMode: PlutoResizeMode.pushAndPull,
              ),
            ),
      columns: columns,
      rows: rows,
      mode: PlutoGridMode.select,
      createFooter: createFooter,
    );
  }
}
