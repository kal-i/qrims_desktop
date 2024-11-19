import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluid_dialog/fluid_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';

import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_popup_menu.dart';
import '../../../../core/common/components/custom_search_box.dart';
import '../../../../core/common/components/error_message_container.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/reusable_data_table.dart';
import '../../../../core/common/components/reusable_dynamic_filter_menu.dart';
import '../../../../core/common/components/reusable_filter_custom_outline_button.dart';
import '../../../../core/common/components/reusable_popup_menu_button.dart';
import '../../../../core/common/components/reusable_popup_menu_container.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';

import '../../../../core/common/components/slideable_container.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/services/item_suggestions_service.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../injection_container.dart';
import '../bloc/item_inventory_bloc.dart';
import '../components/filter_item_modal.dart';

class ItemInventoryView extends StatefulWidget {
  const ItemInventoryView({super.key});

  @override
  State<ItemInventoryView> createState() => _ItemInventoryViewState();
}

class _ItemInventoryViewState extends State<ItemInventoryView> {
  late ItemInventoryBloc _itemInventoryBloc;
  late String _selectedSortValue = 'acquired_date';

  late String? _selectedManufacturer;
  late String? _selectedBrand;
  late AssetClassification? _selectedClassificationFilter;
  late AssetSubClass? _selectedSubClassFilter;

  final ValueNotifier<String> _selectedSortOrder = ValueNotifier('Descending');
  final ValueNotifier<String> _selectedFilterNotifier =
      ValueNotifier('in_stock');

  final ValueNotifier<int> _totalItemsCount = ValueNotifier(0);
  final ValueNotifier<int> _inStockCount = ValueNotifier(0);
  final ValueNotifier<int> _lowStockCount = ValueNotifier(0);
  final ValueNotifier<int> _outOfStockCount = ValueNotifier(0);

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _debounce;

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;

  bool _isLoading = false;
  String? _errorMessage;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Item Name',
    'Description',
    'Brand',
    'Model',
    'Quantity',
    'Unit Cost',
    'Status',
  ];
  late List<TableData> _tableRows = [];

  @override
  void initState() {
    super.initState();
    _itemInventoryBloc = context.read<ItemInventoryBloc>();

    _selectedManufacturer = null;
    _selectedBrand = null;
    _selectedClassificationFilter = null;
    _selectedSubClassFilter = null;

    _searchController.addListener(_onSearchChanged);
    _selectedFilterNotifier.addListener(_onFilterChanged);
    _initializeTableConfig();
    _fetchItems();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [2, 3, 2, 2, 2, 2, 2],
    );
  }

  void _fetchItems() {
    _itemInventoryBloc.add(
      FetchItems(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        filter: _selectedFilterNotifier.value,
        sortBy: _selectedSortValue,
        sortAscending: _selectedSortOrder.value == 'Ascending',
        manufacturerName: _selectedManufacturer,
        brandName: _selectedBrand,
        classificationFilter: _selectedClassificationFilter,
        subClassFilter: _selectedSubClassFilter,
      ),
    );
  }

  void _refreshItemList() {
    _searchController.clear();
    _currentPage = 1;

    _selectedManufacturer = null;
    _selectedBrand = null;
    _selectedClassificationFilter = null;
    _selectedSubClassFilter = null;

    _selectedFilterNotifier.value = 'in_stock';
    _selectedSortValue = '';
    _selectedSortOrder.value = 'Descending';
    _fetchItems();
  }

  void _onFilterChanged() {
    _searchController.clear();
    _currentPage = 1;
    _fetchItems();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _selectedSortOrder.dispose();
    _selectedFilterNotifier.dispose();
    _totalItemsCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20.0,
        ),
        _buildHeaderRow(),
        const SizedBox(
          height: 20.0,
        ),
        _buildSummaryRow(),
        const SizedBox(
          height: 40.0,
        ),
        _buildTableRelatedActionsRow(),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            _buildRegisterButton(),
          ],
        ),
      ],
    );
  }

  /// add status based on the quantity: in stock, low, and out
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _totalItemsCount,
              builder: (context, totalItemsCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageAdd,
                  title: 'Total Items',
                  data: totalItemsCount.toString(),
                  baseColor: Colors.transparent,
                );
              }),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _inStockCount,
              builder: (context, inStockCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageDelivered,
                  title: 'In stock',
                  data: inStockCount.toString(),
                  baseColor: Colors.transparent,
                );
              }),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _lowStockCount,
              builder: (context, lowStockCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageProcess,
                  title: 'Low stock',
                  data: lowStockCount.toString(),
                  baseColor: Colors.transparent,
                );
              }),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _outOfStockCount,
              builder: (context, outOfStockCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageRemove,
                  title: 'Out of stock',
                  data: outOfStockCount.toString(),
                  baseColor: Colors.transparent,
                );
              }),
        ),
      ],
    );
  }

  Widget _buildTableRelatedActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterTableRow(),
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
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'In Stock': 'in_stock',
      'Low': 'low',
      'Out': 'out',
    };
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
    );
  }

  Widget _buildRegisterButton() {
    final Map<String, dynamic> extra = {
      'is_update': false,
    };

    return CustomFilledButton(
      width: 160.0,
      height: 40.0,
      onTap: () => context.go(
        RoutingConstants.nestedRegisterItemViewRoutePath,
        extra: extra,
      ),
      prefixWidget: const Icon(
        HugeIcons.strokeRoundedDeliveryBox01,
        size: 15.0,
        color: AppColor.lightPrimary,
      ),
      text: 'Register Item',
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(
      onTap: _refreshItemList,
    );
  }

  Widget _buildFilterButton() {
    return CustomIconButton(
      tooltip: 'Filter',
      onTap: () => showDialog(
        context: context,
        builder: (context) => FilterItemModal(
          onApplyFilters:
              (String? manufacturer, String? brand, AssetClassification? classification, AssetSubClass? subClass) {
            _selectedManufacturer = manufacturer;
            _selectedBrand = brand;
            _selectedClassificationFilter = classification;
            _selectedSubClassFilter = subClass;
            print('selected: $manufacturer-$brand');
            _fetchItems();
          },
          selectedManufacturer: _selectedManufacturer,
          selectedBrand: _selectedBrand,
          selectedClassificationFilter: _selectedClassificationFilter,
          selectedSubClassFilter: _selectedSubClassFilter,
        ),
      ),
      isOutlined: true,
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildSortButton() {
    return CustomIconButton(
      tooltip: 'Sort',
      onTap: () {}, // _isSortModalVisible.value = true,
      isOutlined: true,
      icon: FluentIcons.text_sort_ascending_20_regular,
    );
  }

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

        if (state is ItemsLoaded) {
          _isLoading = false;
          _totalRecords = state.totalItemCount;
          print(_totalRecords);
          _inStockCount.value = state.inStockCount;
          _lowStockCount.value = state.lowStockCount;
          _outOfStockCount.value = state.outOfStockCount;
          _totalItemsCount.value = _inStockCount.value +
              _lowStockCount.value +
              _outOfStockCount.value;
          _tableRows.clear();
          _tableRows.addAll(
            state.items
                .map(
                  (item) => TableData(
                    id: item.itemEntity.id,
                    columns: [
                      Text(
                        capitalizeWord(
                            item.productStockEntity.productName.name),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        item.productStockEntity.productDescription
                                ?.description ??
                            '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.manufacturerBrandEntity.brand.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.modelEntity.modelName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.itemEntity.quantity.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        item.itemEntity.unitCost.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(
                        width: 50.0,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusHighlighter(
                            item.itemEntity.quantity,
                          ),
                        ),
                      ),
                    ],
                    menuItems: [
                      {'text': 'View', 'icon': FluentIcons.eye_12_regular},
                      {'text': 'Edit', 'icon': FluentIcons.edit_12_regular},
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
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomDataTable(
                      config: _tableConfig.copyWith(
                        rows: _tableRows,
                      ),
                      onActionSelected: (index, action) {
                        final itemId = _tableRows[index].id;
                        String? path;
                        final Map<String, dynamic> extras = {
                          'item_id': itemId,
                        };

                        if (action.isNotEmpty) {
                          if (action.contains('View')) {
                            extras['is_update'] = false;
                            path = RoutingConstants.nestedViewItemRoutePath;
                          }

                          if (action.contains('Edit')) {
                            extras['is_update'] = true;
                            path =
                                RoutingConstants.nestedUpdateItemViewRoutePath;
                          }

                          context.go(
                            path!,
                            extra: extras,
                          );
                        }
                      },
                    ),
                  ),
                  if (_isLoading)
                    LinearProgressIndicator(
                      backgroundColor: Theme.of(context).dividerColor,
                      color: AppColor.accent,
                    ),
                  if (_errorMessage != null)
                    Center(
                      child: CustomMessageBox.error(
                        message: _errorMessage!,
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
      },
    );
  }

  StatusStyle _quantityStatusStyler({required int quantity}) {
    if (quantity > 5) {
      return StatusStyle.green(label: 'In Stock');
    } else if (quantity > 0) {
      return StatusStyle.yellow(label: 'Low');
    } else {
      return StatusStyle.red(label: 'Out');
    }
  }

  Widget _buildStatusHighlighter(int quantity) {
    return HighlightStatusContainer(
      statusStyle: _quantityStatusStyler(quantity: quantity),
    );
  }
}
