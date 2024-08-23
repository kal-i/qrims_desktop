import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';

import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/error_message_container.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_data_table.dart';
import '../../../../core/common/components/reusable_popup_menu_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../bloc/item_inventory_bloc.dart';

class ItemInventoryView extends StatefulWidget {
  const ItemInventoryView({super.key});

  @override
  State<ItemInventoryView> createState() => _ItemInventoryViewState();
}

class _ItemInventoryViewState extends State<ItemInventoryView> {
  final List<DataColumn2> _columns = [];
  final List<DataRow2> _rows = [];
  late ItemInventoryBloc _itemInventoryBloc;

  final ValueNotifier<String> _selectedSortOrder = ValueNotifier('Descending');
  final ValueNotifier<Set<int>> _selectedRowIndices =
      ValueNotifier<Set<int>>(<int>{});

  late String _selectedSortValue = 'id';

  late AssetClassification? _selectedClassificationFilter;
  late AssetSubClass? _selectedSubClassFilter;

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _denounce;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;

  bool _isLoading = false;
  String? _errorMessage;

  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    _itemInventoryBloc = context.read<ItemInventoryBloc>();
    _selectedClassificationFilter = null;
    _selectedSubClassFilter = null;
    _initializeColumns();
    _searchController.addListener(_onSearchChanged);
    _fetchItems();
  }

  void _initializeColumns() {
    _columns.addAll(
      [
        // const DataColumn2(
        //   label: Text('Item Id'),
        // ),
        // const DataColumn2(
        //   label: Text('Specification'),
        // ),
        const DataColumn2(label: Text('Item Name'),),
        const DataColumn2(label: Text('Description'),),
        const DataColumn2(
          label: Text('Brand'),
        ),
        const DataColumn2(
          label: Text('Model'),
        ),

        // const DataColumn2(
        //   label: Text('Serial No'),
        // ),
        // const DataColumn2(
        //   label: Text('Manufacturer'),
        // ),
        // const DataColumn2(
        //   label: Text('Asset Classification'),
        // ),
        // const DataColumn2(
        //   label: Text('Asset Sub Class'),
        // ),
        // const DataColumn2(
        //   label: Text('Unit'),
        // ),

        const DataColumn2(
          label: Text('Quantity'),
        ),
        const DataColumn2(
          label: Text('Unit Cost'),
        ),
        // const DataColumn2(
        //   label: Text('Estimated Useful Life'),
        // ),
        // const DataColumn2(
        //   label: Text('Acquired Date'),
        // ),
        // const DataColumn2(
        //   label: Text('QR Code'),
        // ),
        const DataColumn2(
          label: Text('Actions'),
        ),
      ],
    );
  }

  void _fetchItems() {
    _itemInventoryBloc.add(
      FetchItems(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        sortBy: _selectedSortValue,
        sortAscending: _selectedSortOrder.value == 'Ascending',
        classificationFilter: _selectedClassificationFilter,
        subClassFilter: _selectedSubClassFilter,
      ),
    );
  }

  void _refreshItemList() {
    _searchController.clear();
    _currentPage = 1;
    _selectedClassificationFilter = null;
    _selectedSubClassFilter = null;
    _fetchItems();
  }

  void _onSearchChanged() {
    if (_denounce?.isActive ?? false) _denounce?.cancel();
    _denounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchItems();
    });
  }

  Future<Uint8List> generatePdfWithQrCode(Uint8List qrCodeImageBytes) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(qrCodeImageBytes),
              width: 200, // Adjust width as needed
              height: 200, // Adjust height as needed
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  void printQrCode(Uint8List qrCodeImageBytes) async {
    final pdfData = await generatePdfWithQrCode(qrCodeImageBytes);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }

  void _showQrCodeDialog(String qrCodeImageData) {
    final qrCodeImageBytes = base64Decode(qrCodeImageData);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Container(
          padding: const EdgeInsets.all(10.0),
          width: 300.0,
          height: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scan the QR Code to view item\'s information',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Container(
                width: 240.0,
                height: 240.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Image.memory(
                  base64Decode(qrCodeImageData),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomOutlineButton(
            onTap: () => context.pop(),
            text: 'Close',
          ),
          CustomOutlineButton(
            onTap: () async {
              printQrCode(qrCodeImageBytes);
            },
            icon: CupertinoIcons.printer,
            text: 'Print',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _denounce?.cancel();
    _selectedSortOrder.dispose();
    _selectedRowIndices.dispose();
    super.dispose();
  }

  /// Note: for items with serial no, register separately

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSummaryRow(),
        ),
        const SizedBox(
          height: 50.0,
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildActionsRow(),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: _buildDataTable(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return const Row(
      children: [
        Expanded(
          child: KPICard(
            icon: Icons.inventory_2_outlined,
            title: 'Total Items',
            data: '20',
            baseColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: KPICard(
            icon: CupertinoIcons.cube,
            title: 'In stock',
            data: '10',
            baseColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: KPICard(
            icon: CupertinoIcons.cube_box,
            title: 'Low stock',
            data: '5',
            baseColor: Colors.transparent,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: KPICard(
            icon: CupertinoIcons.nosign,
            title: 'Out of stock',
            data: '5',
            baseColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRegisterButton(),
        Row(
          children: [
            ExpandableSearchButton(
              controller: _searchController,
            ),
            const SizedBox(
              width: 10.0,
            ),
            _buildRefreshButton(),
            const SizedBox(
              width: 10.0,
            ),
            _buildFilterButton(),
            const SizedBox(
              width: 10.0,
            ),
            _buildSortButton(),
            // const SizedBox(
            //   width: 10.0,
            // ),
            //_buildFilterColumnButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    final Map<String, dynamic> extra = {
      'is_update': false,
    };

    return CustomFilledButton(
      onTap: () => context.go(
        '${RoutingConstants.itemInventoryViewRoutePath}/${RoutingConstants.registerItemViewRoutePath}',
        extra: extra,
      ),
      text: 'Register item',
    );
  }

  Widget _buildRefreshButton() {
    return CustomIconButton(
      onTap: () => _refreshItemList(),
      tooltip: 'Refresh',
      icon: CupertinoIcons.arrow_2_circlepath,
    );
  }

  Widget _buildFilterButton() {
    return ReusablePopupMenuButton(
      onSelected: _onFilterSelected,
      tooltip: 'Filter',
      icon: const CustomIconButton(
        icon: Icons.tune_outlined,
      ),
      popupMenuItems: _buildFilterMenuItems(),
    );
  }

  List<PopupMenuEntry<String>> _buildFilterMenuItems() {
    return [
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        title: 'Filter by:',
      ),
      const PopupMenuDivider(
        height: .3,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        title: 'Asset Classification:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetClassification.buildingsAndStructure.toString(),
        title: 'Buildings and Structure',
        icon: CupertinoIcons.building_2_fill,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetClassification.machineryAndEquipment.toString(),
        title: 'Machinery and Equipment',
        icon: CupertinoIcons.cube_box,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetClassification.transportation.toString(),
        title: 'Transportation',
        icon: Icons.fire_truck_outlined,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetClassification.furnitureFixturesAndBooks.toString(),
        title: 'Furniture Fixtures and Books',
        icon: CupertinoIcons.book,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetClassification.unknown.toString(),
        title: 'Unknown',
        icon: CupertinoIcons.question_square,
      ),
      const PopupMenuDivider(
        height: .3,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        title: 'Asset Sub Class:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.schoolBuildings.toString(),
        title: 'School Buildings',
        icon: CupertinoIcons.building_2_fill,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.machinery.toString(),
        title: 'Machinery',
        icon: CupertinoIcons.cube_box,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.office.toString(),
        title: 'Office',
        icon: Icons.fire_truck_outlined,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.informationAndCommunicationTechnologyEquipment
            .toString(),
        title: 'Information And Communication Technology Equipment',
        icon: CupertinoIcons.book,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.medical.toString(),
        title: 'Medical',
        icon: CupertinoIcons.question_square,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.dental.toString(),
        title: 'Dental',
        icon: CupertinoIcons.book,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.sports.toString(),
        title: 'Sports',
        icon: CupertinoIcons.question_square,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.motorVehicles.toString(),
        title: 'Motor Vehicles',
        icon: CupertinoIcons.book,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.furnitureAndBooks.toString(),
        title: 'Furniture and Books',
        icon: CupertinoIcons.question_square,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: AssetSubClass.unknown.toString(),
        title: 'Unknown',
        icon: CupertinoIcons.question_square,
      ),
    ];
  }

  void _onFilterSelected(String? value) {
    print(value);
    if (value != null && value.isNotEmpty) {
      if (value.startsWith('AssetClassification')) {
        _selectedSubClassFilter = null;
        _selectedClassificationFilter = AssetClassification.values.firstWhere(
          (e) => e.toString().split('.').last == value.split('.').last,
        );
      } else if (value.startsWith('AssetSubClass')) {
        _selectedSubClassFilter = AssetSubClass.values.firstWhere(
          (e) => e.toString().split('.').last == value.split('.').last,
        );
      }

      print(_selectedClassificationFilter);
      print(_selectedSubClassFilter);
      _searchController.clear();
      _currentPage = 1;
      _fetchItems();
    }
  }

  Widget _buildSortButton() {
    return ValueListenableBuilder(
        valueListenable: _selectedSortOrder,
        builder: (BuildContext context, String value, Widget? child) {
          return ReusablePopupMenuButton(
            onSelected: _onSortSelected,
            tooltip: 'Sort',
            icon: const CustomIconButton(
              icon: CupertinoIcons.arrow_up_arrow_down,
            ),
            popupMenuItems: _buildSortMenuItems(),
          );
        });
  }

  List<PopupMenuEntry<String>> _buildSortMenuItems() {
    return [
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        title: 'Sort by:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
          context: context,
          value: 'id',
          title: 'Item Id',
          icon: Icons.discount_outlined),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'quantity',
        title: 'Quantity',
        icon: CupertinoIcons.cube_box,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'unit_cost',
        title: 'Unit Cost',
        icon: CupertinoIcons.money_dollar_circle,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'estimated_useful_life',
        title: 'Estimated Useful Life',
        icon: CupertinoIcons.heart,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'acquired_date',
        title: 'Acquired Date',
        icon: CupertinoIcons.calendar,
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        title: 'Sort order:',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        leading: RadioMenuButton<String>(
          value: 'Ascending',
          groupValue: _selectedSortOrder.value,
          onChanged: (value) {
            if (value != null) {
              _selectedSortOrder.value = value;
              _fetchItems();
              // todo: temp sol is to close after picking a sort order val since ui changes do not reflect
              context.pop();
            }
          },
          child: Text(
            'Ascending',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ), // widget instead
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        leading: RadioMenuButton(
          value: 'Descending',
          groupValue: _selectedSortOrder.value,
          onChanged: (value) {
            if (value != null) {
              _selectedSortOrder.value = value;
              _fetchItems();
              context.pop();
            }
          },
          child: Text(
            'Descending',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    ];
  }

  void _onSortSelected(String? value) {
    if (value != null && value.isNotEmpty) {
      _selectedSortValue = value;
      _fetchItems();
    }
  }

  // Widget _buildUpdateButton() {
  //   return CustomIconButton(
  //     onTap: _onSelectUpdate,
  //     icon: CupertinoIcons.pencil,
  //   );
  // }

  void _onSelectUpdate() {
    print(_rows);
    final selectedRowIndex = _selectedRowIndices.value.isNotEmpty
        ? _selectedRowIndices.value.first
        : -1;

    if (selectedRowIndex == -1) {
      return;
    }

    final selectedRow = _rows[selectedRowIndex];

    print('selected row index: $selectedRowIndex');
    print('selected row: $selectedRow');

    final firstCell =
        selectedRow.cells.isNotEmpty ? selectedRow.cells.first : null;

    if (firstCell != null) {
      // Extract the data from DataCell
      final firstCellValueWidget = firstCell.child as Text?;
      final firstCellValue = firstCellValueWidget?.data ?? '';
      print('first cell value: $firstCellValue');

      // Safely parse the value to an integer
      final itemId = int.tryParse(firstCellValue) ?? -1;

      if (itemId != -1) {
        final Map<String, dynamic> extras = {
          'is_update': true,
          'item_id': itemId,
        };
        context.go(
          '${RoutingConstants.itemInventoryViewRoutePath}/${RoutingConstants.updateItemViewRoutePath}',
          extra: extras,
        );
      } else {
        print('Invalid item_id: $firstCellValue');
      }
    } else {
      print('No cells available in the selected row.');
    }
  }

  List<PopupMenuEntry<String>> _buildActionMenuItems() {
    return [
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'view',
        icon: Icons.file_copy_outlined,
        title: 'View',
      ),
      ReusablePopupMenuButton.reusableListTilePopupMenuItem(
        context: context,
        value: 'edit',
        icon: Icons.edit,
        title: 'Edit',
      ),
    ];
  }

  void _onActionView(int id) {
    final Map<String, dynamic> extras = {
      'is_update': false,
      'item_id': id,
    };

    context.go(
      '${RoutingConstants.itemInventoryViewRoutePath}/${RoutingConstants.updateItemViewRoutePath}',
      extra: extras,
    );
  }

  void _onActionUpdate(int id) {
    final Map<String, dynamic> extras = {
      'is_update': true,
      'item_id': id,
    };

    context.go(
      '${RoutingConstants.itemInventoryViewRoutePath}/${RoutingConstants.updateItemViewRoutePath}',
      extra: extras,
    );
  }

  // Widget _buildFilterColumnButton() {
  //   return ReusablePopupMenuButton(
  //     icon: const CustomIconButton(
  //       icon: Icons.view_week_outlined, // Icons.view_in_ar_outlined,
  //     ),
  //     onSelected: (String? value) {},
  //     popupMenuItems: [],
  //   );
  // }

  Widget _buildDataTable() {
    return BlocConsumer<ItemInventoryBloc, ItemInventoryState>(
        listener: (context, state) {
      if (state is ItemsLoading) {
        _isLoading = true;
        _errorMessage = null;
      }

      // no need to trigger refresh when just fetching data
      if (state is ItemFetched) {
        _isLoading = false;
      }

      // just to reset the loading state
      if (state is ItemRegistered || state is ItemUpdated) {
        _isLoading = false;
        _refreshItemList();
      }

      // if (state is ItemRegistered) {
      //   _refreshItemList();
      // }
      //
      // if (state is ItemUpdated) {
      //   _refreshItemList();
      // }

      if (state is ItemsLoaded) {
        _isLoading = false;
        _totalRecords = state.totalItemCount;
        _rows.clear();
        _rows.addAll(
          state.items
              .map(
                (item) => DataRow2(
                  cells: [
                    //DataCell(Text(item.id.toString())),
                    // DataCell(Text(
                    //   item.specification,
                    //   overflow: TextOverflow.ellipsis,
                    // )),
                    DataCell(Text(item.stockEntity!.productName),),
                    DataCell(Text(item.stockEntity!.description),),
                    DataCell(Text(item.itemEntity.brand,)),
                    DataCell(Text(item.itemEntity.model,)),

                    // DataCell(Text(item.itemEntity.serialNo!)),
                    // DataCell(Text(item.itemEntity.manufacturer)),
                    // DataCell(Text(readableEnumConverter(item.itemEntity.assetClassification!))),
                    // DataCell(Text(readableEnumConverter(item.itemEntity.assetSubClass!))),
                    // DataCell(Text(readableEnumConverter(item.itemEntity.unit))),

                    DataCell(Text(item.itemEntity.quantity.toString(),)),
                    DataCell(Text(item.itemEntity.unitCost.toString(),)),
                    //DataCell(Text(item.estimatedUsefulLife.toString())),
                    //DataCell(Text(dateFormatter(item.acquiredDate!))),
                    // DataCell(
                    //   Padding(
                    //     padding: const EdgeInsets.all(5.0),
                    //     child: GestureDetector(
                    //       onTap: () => _showQrCodeDialog(item.qrCodeImageData),
                    //       child: Image.memory(
                    //         base64Decode(item.qrCodeImageData),
                    //         fit: BoxFit.cover,
                    //         height: 50.0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    DataCell(
                      ReusablePopupMenuButton(
                        onSelected: (String? value) {
                          String basePath =
                              '${RoutingConstants.itemInventoryViewRoutePath}/';
                          final Map<String, dynamic> extras = {
                            'item_id': item.itemEntity.id,
                          };

                          print(item.itemEntity.id);

                          if (value != null && value.isNotEmpty) {
                            if (value.contains('view')) {
                              extras['is_update'] = false;
                              basePath += RoutingConstants.viewItemRoutePath;
                            }

                            if (value.contains('edit')) {
                              extras['is_update'] = true;
                              basePath +=
                                  RoutingConstants.updateItemViewRoutePath;
                            }

                            context.go(
                              basePath,
                              extra: extras,
                            );
                          }
                        },
                        popupMenuItems: _buildActionMenuItems(),
                      ),
                      // Row(
                      //   children: [
                      //     CustomIconButton(
                      //       tooltip: 'View',
                      //       icon: Icons.file_copy_outlined,
                      //       onTap: () => _onActionUpdate(item.id),
                      //     ),
                      //     const SizedBox(
                      //       width: 5.0,
                      //     ),
                      //     CustomIconButton(
                      //       tooltip: 'Edit',
                      //       icon: Icons.edit,
                      //       onTap: () => _onActionUpdate(item.id),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              )
              .toList(),
        );
      }

      if (state is ItemsError) {
        _isLoading = false;
        _errorMessage = state.message;
      }
    }, builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _selectedRowIndices,
                    builder: (BuildContext context, Set<int> selectedRowIndices,
                        Widget? child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: ReusableDataTable(
                                      columns: _columns, // _columns,
                                      rows: _rows.map((row) {
                                        final index = _rows.indexOf(row);

                                        return DataRow2(
                                          cells: row.cells,
                                          selected: selectedRowIndices.contains(index),
                                          onSelectChanged: (selected) {
                                            if (selected != null) {
                                              final updatedSelected =
                                                  Set<int>.from(selectedRowIndices);
                                              if (selected) {
                                                updatedSelected.add(index);
                                              } else {
                                                updatedSelected.remove(index);
                                              }
                                              _selectedRowIndices.value = updatedSelected;
                                            }
                                          },
                                          color: WidgetStateProperty.resolveWith<Color?>(
                                              (Set<WidgetState> states) {
                                            if (states.contains(WidgetState.hovered)) {
                                              return Theme.of(context)
                                                  .dividerColor
                                                  .withOpacity(0.3);
                                            } else if (states
                                                .contains(WidgetState.selected)) {
                                              return Theme.of(context)
                                                  .dividerColor
                                                  .withOpacity(0.3);
                                            }
                                            return null;
                                            // return context.watch<ThemeBloc>().state == AppTheme.light
                                            //     ? AppColor.lightTableRow
                                            //     : AppColor.darkTableRow;
                                          }),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                            ),
                          );
                        }
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Container(
                    height: 2.0,
                    color: AppColor.accent,
                  ),
                if (_errorMessage != null)
                  Center(
                    child: ErrorMessageContainer(
                      errorMessage: _errorMessage!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          PaginationControls(
            currentPage: _currentPage,
            totalRecords: _totalRecords,
            pageSize: _pageSize,
            onPageChanged: (page) {
              _currentPage = page;
              _fetchItems();
            },
            onPageSizeChanged: (size) {
              _pageSize = size;
              _fetchItems();
            },
          ),
        ],
      );
    });
  }
}
