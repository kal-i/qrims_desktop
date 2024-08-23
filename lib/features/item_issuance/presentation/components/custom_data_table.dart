import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';

/// Model class representing the row's data
class TableData {
  TableData({
    required this.columns,
    this.isSelected = false,
    this.onSelected,
  });

  /// Widgets representing the content
  final List<Widget> columns;

  /// Indicates whether the row is selected
  bool isSelected;

  /// Callback when row is selected or not
  final ValueChanged<bool>? onSelected;
}

/// Config class representing the table structure
class TableConfig {
  const TableConfig({
    required this.headers,
    required this.rows,
  });

  final List<String> headers;
  final List<TableData> rows;
}

/// Custom Widget displaying a table
class CustomDataTable extends StatefulWidget {
  const CustomDataTable({
    super.key,
    required this.config,
    this.onRowSelected,
    this.onActionSelected,
  });

  final TableConfig config;
  final ValueChanged<int>? onRowSelected;
  final ValueChanged<int>? onActionSelected;

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int? _hoverIndex;
  final ValueNotifier<bool> _selectAll = ValueNotifier(false);
  late final ValueNotifier<List<bool>> _rowSelectionStates;
  
  @override
  void initState() {
    super.initState();
    _rowSelectionStates = ValueNotifier(widget.config.rows.map((row) => row.isSelected).toList());
  }

  void _toggleSelectAll(bool? value) {
    _selectAll.value = value ?? false;
    final updatedStates = List<bool>.filled(widget.config.rows.length, _selectAll.value);

    _rowSelectionStates.value = updatedStates;
    for (int i = 0; i < widget.config.rows.length; i++) {
      widget.config.rows[i].isSelected = _selectAll.value;

      if (widget.config.rows[i].onSelected != null) {
        widget.config.rows[i].onSelected!(_selectAll.value);
      }
    }
  }

  void _onRowTap(int index) {
    final updatedStates = List<bool>.from(_rowSelectionStates.value);
    updatedStates[index] = !updatedStates[index]; // Toggle selection

    widget.config.rows[index].isSelected = updatedStates[index];
    widget.config.rows[index].onSelected?.call(updatedStates[index]);

    // Check if all rows are selected to update the "select all" checkbox state
    _selectAll.value = updatedStates.every((isSelected) => isSelected);

    _rowSelectionStates.value = updatedStates;
    if (widget.onRowSelected != null) {
      widget.onRowSelected!(index);
    }
  }

  void _onRowSelected(int index, bool? value) {
    final updatedStates = List<bool>.from(_rowSelectionStates.value);
    updatedStates[index] = value ?? false;
    
    /// Set the updated value to that specific row
    widget.config.rows[index].isSelected = updatedStates[index];
    widget.config.rows[index].onSelected?.call(updatedStates[index]);
    
    _selectAll.value = updatedStates.every((isSelected) => isSelected);

    _rowSelectionStates.value = updatedStates;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverStickyHeader(
          header: ValueListenableBuilder(
            valueListenable: _selectAll,
            builder: (context, selectAllValue, child) {
              return Container(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0,),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: context.watch<ThemeBloc>().state == AppTheme.light
                      ? AppColor.lightSecondary
                      : AppColor.darkSecondary,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectAll.value,
                      onChanged: _toggleSelectAll,
                    ),

                    /// Header columns' data
                    ...widget.config.headers.map(
                      (header) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            header,
                            textAlign: TextAlign.left,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ),
                    ),

                    /// Spacer to align with the more ver icon in rows
                    const SizedBox(width: 48.0,),
                  ],
                ),
              );
            }
          ),
          sliver: ValueListenableBuilder(
            valueListenable: _rowSelectionStates,
            builder: (context, rowSelectionStates, child) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index >= widget.config.rows.length) {
                      return null;
                    }

                    final rowData = widget.config.rows[index];
                    final isHovered = _hoverIndex == index;
                    final isSelected = rowSelectionStates[index];

                    return MouseRegion(
                      onEnter: (_) => setState(() {
                        _hoverIndex = index;
                      }),
                      onExit: (_) => setState(() {
                        _hoverIndex = null;
                      }),
                      child: GestureDetector(
                        onTap: () => _onRowTap(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          height: 70.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: isSelected ? Theme.of(context).dividerColor.withOpacity(0.2) : isHovered ? Theme.of(context).dividerColor.withOpacity(0.2) : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              /// Check box
                              Checkbox(
                                value: rowSelectionStates[index],
                                onChanged: (value) => _onRowSelected(index, value),
                              ),

                              /// Row columns' data
                              ...rowData.columns.map(
                                (columnData) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: columnData,
                                  ),
                                ),
                              ),

                              // More vert icon
                              IconButton(
                                onPressed: () {
                                  if (widget.onActionSelected != null) {
                                    widget.onActionSelected!(index);
                                  }
                                },
                                icon: const Icon(
                                  Icons.more_vert_outlined,
                                  size: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: widget.config.rows.length,
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
