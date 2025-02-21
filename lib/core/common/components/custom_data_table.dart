import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../config/themes/app_color.dart';
import '../../../config/themes/app_theme.dart';
import '../../../config/themes/bloc/theme_bloc.dart';

/// Model class representing the row's data
/// This class holds data for each row in the table, including its ID, content (columns),
/// selection state, and context menu items.
class TableData<T> {
  TableData({
    required this.id,
    required this.columns,
    this.isSelected = false,
    this.menuItems,
    this.object,
  });

  /// Represents the table row's ID fetched from the data source.
  final String id;

  /// Widgets representing the content of each column in the row.
  final List<Widget> columns;

  /// Indicates whether the row is selected.
  bool isSelected;

  /// List of context menu items that can be triggered on this row.
  final List<Map<String, dynamic>>? menuItems;

  final T? object;
}

/// Config class representing the table structure
/// This class holds the configuration of the table, such as headers and rows.
class TableConfig<T> {
  const TableConfig({
    required this.headers,
    required this.rows,
    this.columnFlex,
  });

  /// List of header labels for the columns.
  final List<String> headers;

  /// List of rows to be displayed in the table.
  final List<TableData> rows;

  /// Optional flex values for columns to control their width ratios.
  final List<int>? columnFlex;

  /// Creates a new instance of [TableConfig] with optional overridden values.
  TableConfig<T> copyWith({
    List<String>? headers,
    List<TableData>? rows,
    List<int>? columnFlex,
  }) {
    return TableConfig(
      headers: headers ?? this.headers,
      rows: rows ?? this.rows,
      columnFlex: columnFlex ?? this.columnFlex,
    );
  }
}

/// Custom Widget displaying a table
/// This widget builds a scrollable table with sticky headers and customizable rows.
class CustomDataTable extends StatefulWidget {
  const CustomDataTable({
    super.key,
    required this.config,
    this.onActionSelected,
    this.onRowSelected,
  });

  /// The configuration of the table, including headers and rows.
  final TableConfig config;

  /// Callback function triggered when a menu action is selected for a row.
  final void Function(int rowIndex, String action)? onActionSelected;
  final void Function(int rowIndex)? onRowSelected;

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int? _selectedRowIndex;
  int? _hoveredRowIndex;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Check if there are rows available in the table.
    final hasRows = widget.config.rows.isNotEmpty;

    /// Get the flex values for columns or use empty list if not provided.
    final columnFlex = widget.config.columnFlex ?? [];

    return CustomScrollView(
      slivers: [
        /// Sticky header for the table.
        SliverStickyHeader(
          header: Container(
            height: 50.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),

              /// Header color depends on the current theme (light/dark).
              color: context.watch<ThemeBloc>().state == AppTheme.light
                  ? AppColor.lightPrimary
                  : AppColor.darkSecondary,
            ),
            child: Row(
              children: [
                /// Checkbox for selecting/deselecting all rows.
                Checkbox(
                  activeColor: AppColor.accent,
                  value: false,
                  onChanged: (isSelectedAll) {},
                ),

                /// Header columns' data
                ...widget.config.headers.asMap().entries.map(
                  (entry) {
                    int index = entry.key;
                    String header = entry.value;
                    int flexValue =
                        columnFlex.isNotEmpty && index < columnFlex.length
                            ? columnFlex[index]
                            : 1; // Default flex value if not provided.

                    return Expanded(
                      flex: flexValue,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          header,
                          textAlign: TextAlign.left,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    );
                  },
                ),

                /// Spacer to align with the more icon in rows.
                const SizedBox(
                  width: 48.0,
                ),
              ],
            ),
          ),

          /// The body of the table, containing the rows.
          sliver: hasRows
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (index >= widget.config.rows.length) {
                        return null;
                      }

                      final rowData = widget.config.rows[index];

                      /// MouseRegion to detect hover events over the row.
                      return MouseRegion(
                        onEnter: (_) {
                          print('Hovered over row $index');
                          setState(() {
                            _hoveredRowIndex = index;
                          });
                        },
                        onExit: (_) {
                          print('Mouse exited row $index');
                          setState(() {
                            _hoveredRowIndex = null;
                          });
                        },

                        /// GestureDetector to detect taps on the row.
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedRowIndex == index) {
                                // If already selected, deselect
                                _selectedRowIndex = null;
                                rowData.isSelected = false;
                              } else {
                                // Select this row
                                _selectedRowIndex = index;
                                rowData.isSelected = true;
                              }
                            });

                            // Trigger callback after updating state
                            widget.onRowSelected?.call(index);
                            //setState(() {
                            ///_selectedRowIndex =
                            // _selectedRowIndex == index ? null : index;
                            //rowData.isSelected = _selectedRowIndex == index;
                            //});
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            height: 70.0,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1.0,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(
                                  0.0), // set border radius to 0 if we will add a border, otherwise set to 10.0
                              color: _selectedRowIndex == index
                                  ? Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.2)
                                  : _hoveredRowIndex == index
                                      ? Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.1)
                                      : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                /// Check box for selecting the individual row.
                                Checkbox(
                                  activeColor: AppColor.accent,
                                  value: rowData.isSelected,
                                  onChanged: (isSelected) {
                                    setState(() {
                                      rowData.isSelected = isSelected ?? false;
                                      if (isSelected != null && isSelected) {
                                        _selectedRowIndex = index;
                                      } else {
                                        _selectedRowIndex = null;
                                      }
                                    });
                                  },
                                ),

                                /// Display columns data for the row.
                                ...rowData.columns.asMap().entries.map(
                                  (entry) {
                                    int index = entry.key;
                                    Widget columnData = entry.value;
                                    int flexValue = columnFlex.isNotEmpty &&
                                            index < columnFlex.length
                                        ? columnFlex[index]
                                        : 1; // Default flex value if not provided.

                                    return Expanded(
                                      flex: flexValue,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: columnData,
                                      ),
                                    );
                                  },
                                ),

                                PopupMenuButton<String>(
                                  elevation: 8.0,
                                  tooltip: 'Actions',
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  onSelected: (action) {
                                    if (widget.onActionSelected != null) {
                                      widget.onActionSelected!(index, action);
                                      setState(() {
                                        rowData.isSelected = false;
                                        if (_selectedRowIndex == index) {
                                          _selectedRowIndex = null;
                                        }
                                      });
                                    }
                                  },
                                  itemBuilder: (context) =>
                                      rowData.menuItems?.map((menuItem) {
                                        return PopupMenuItem<String>(
                                          value: menuItem['text'] as String,
                                          child: ListTile(
                                            leading: menuItem['icon'] != null
                                                ? Icon(
                                                    menuItem['icon'],
                                                    size: 16.0,
                                                  )
                                                : null,
                                            title: Text(
                                              menuItem['text'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            ),
                                          ),
                                        );
                                      }).toList() ??
                                      [],
                                  icon: const Icon(
                                    HugeIcons.strokeRoundedMoreVertical,
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
                )
              : SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80.0,
                    child: Center(
                      child: Text(
                        'No data available.',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
