import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../item_inventory/data/models/inventory_item.dart';
import '../../../item_inventory/data/models/supply.dart';
import '../../../item_inventory/domain/entities/supply.dart';
import '../../../item_inventory/presentation/bloc/item_inventory_bloc.dart';

class ItemSelectionModal extends StatefulWidget {
  const ItemSelectionModal({
    super.key,
    required this.onSelectedItems,
    this.preselectedItems,
    this.excludeItemIds,
  });

  final Function(List<Map<String, dynamic>> selectedItems) onSelectedItems;
  final List<Map<String, dynamic>>? preselectedItems;
  final Set<dynamic>? excludeItemIds;

  @override
  State<ItemSelectionModal> createState() => _ItemSelectionModalState();
}

class _ItemSelectionModalState extends State<ItemSelectionModal> {
  late ItemInventoryBloc _itemInventoryBloc;
  late List<Map<String, dynamic>> _preselectedItems;

  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('supply');
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
    'Quantity',
    'Unit Cost',
  ];
  late List<TableData> _tableRows;

  // Global selection state
  final Set<String> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _itemInventoryBloc = context.read<ItemInventoryBloc>();

    final excludeIds = widget.excludeItemIds ?? {};

    _preselectedItems = (widget.preselectedItems ?? [])
        .where((item) => !excludeIds
            .contains(item['shareable_item_information']['base_item_id']))
        .toList();

    // Initialize selected IDs from preselected items
    _selectedItemIds.addAll(
      _preselectedItems.map((item) =>
          item['shareable_item_information']['base_item_id'].toString()),
    );

    _searchController.addListener(_onSearchChanged);
    _selectedFilterNotifier.addListener(_onFilterChanged);

    _tableRows = [];
    _initializeTableConfig();
    _fetchItems();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [2, 3, 1, 1],
    );
  }

  void _fetchItems() {
    _itemInventoryBloc.add(
      FetchItems(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text,
        filter: _selectedFilterNotifier.value,
      ),
    );
  }

  void _refreshItemList() {
    _searchController.clear();
    _currentPage = 1;
    _selectedFilterNotifier.value = 'supply';
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

  void _selectAllCurrentPage() {
    setState(() {
      for (var row in _tableRows) {
        final itemObj = row.object;
        final newItem = itemObj is SupplyEntity
            ? (itemObj as SupplyModel).toJson()
            : (itemObj as InventoryItemModel).toJson();
        final baseItemId =
            newItem['shareable_item_information']['base_item_id'].toString();

        if (!_selectedItemIds.contains(baseItemId)) {
          _selectedItemIds.add(baseItemId);
          final isDup = _preselectedItems.any((it) =>
              it['shareable_item_information']['base_item_id'].toString() ==
              baseItemId);
          if (!isDup) _preselectedItems.add(newItem);
        }

        row.isSelected = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 1080.0,
      height: 550.0,
      headerTitle: 'Item Inventory',
      subtitle: 'Select item(s) to be issued from the inventory.',
      content: Column(
        children: [
          _buildTableRelatedActionsRow(),
          Expanded(child: _buildDataTable()),
        ],
      ),
      footer: _buildActionsRow(),
    );
  }

  Widget _buildTableRelatedActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterTableRow(),
        Row(
          spacing: 10.0,
          children: [
            ExpandableSearchButton(controller: _searchController),
            _buildRefreshButton(),
            _buildSelectAllButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: {'Supply': 'supply', 'Inventory': 'inventory'},
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(onTap: _refreshItemList);
  }

  Widget _buildSelectAllButton() {
    return CustomOutlineButton(
      onTap: _selectAllCurrentPage,
      text: 'Select All',
      icon: FluentIcons.checkbox_checked_20_regular,
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<ItemInventoryBloc, ItemInventoryState>(
      listener: (context, state) {
        if (state is ItemsLoading) {
          _isLoading = true;
          _errorMessage = null;
        }
        if (state is ItemsLoaded) {
          _isLoading = false;
          _totalRecords = state.totalItemCount;
          _tableRows.clear();

          final excludeIds = widget.excludeItemIds ?? {};

          _tableRows.addAll(
            state.items
                .where(
              (item) =>
                  !excludeIds.contains(item.shareableItemInformationEntity.id),
            )
                .map((item) {
              final id = item.shareableItemInformationEntity.id.toString();
              return TableData(
                id: id,
                object: item,
                // persist selection across pagination:
                isSelected: _selectedItemIds.contains(id),
                columns: [
                  Text(
                    capitalizeWord(item.productStockEntity.productName.name),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    (item.shareableItemInformationEntity.specification ==
                                null ||
                            item.shareableItemInformationEntity.specification
                                    ?.trim()
                                    .isEmpty ==
                                true ||
                            item.shareableItemInformationEntity.specification
                                    ?.toLowerCase() ==
                                'na' ||
                            item.shareableItemInformationEntity.specification
                                    ?.toLowerCase() ==
                                'n/a')
                        ? capitalizeWord(
                            '${item.productStockEntity.productDescription?.description}')
                        : capitalizeWord(
                            '${item.productStockEntity.productDescription?.description}, ${item.shareableItemInformationEntity.specification}'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    item.shareableItemInformationEntity.quantity.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  Text(
                    formatCurrency(
                        item.shareableItemInformationEntity.unitCost),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
                menuItems: [
                  {'text': 'View', 'icon': FluentIcons.eye_12_regular}
                ],
              );
            }).toList(),
          );
        }
        if (state is ItemsError) {
          _isLoading = false;
          _errorMessage = state.message;
        }
        // on supply/inventory registration or update, refresh
        if (state is SupplyItemRegistered ||
            state is InventoryItemRegistered ||
            state is ItemUpdated) {
          _isLoading = false;
          _refreshItemList();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: CustomDataTable(
                config: _tableConfig.copyWith(rows: _tableRows),
                onRowSelected: (index) {
                  setState(() {
                    final row = _tableRows[index];
                    final itemObj = row.object;
                    final newItem = itemObj is SupplyEntity
                        ? (itemObj as SupplyModel).toJson()
                        : (itemObj as InventoryItemModel).toJson();
                    final baseItemId = newItem['shareable_item_information']
                            ['base_item_id']
                        .toString();

                    if (_selectedItemIds.remove(baseItemId)) {
                      _preselectedItems.removeWhere((it) =>
                          it['shareable_item_information']['base_item_id']
                              .toString() ==
                          baseItemId);
                    } else {
                      _selectedItemIds.add(baseItemId);
                      final isDup = _preselectedItems.any((it) =>
                          it['shareable_item_information']['base_item_id']
                              .toString() ==
                          baseItemId);
                      if (!isDup) _preselectedItems.add(newItem);
                    }

                    // update this row’s selected state
                    row.isSelected = _selectedItemIds.contains(baseItemId);
                  });
                },
                onActionSelected: (index, action) {
                  final row = _tableRows[index];
                  final itemId = row.id;
                  final itemObj = row.object;
                  String? path;
                  final extras = {'item_id': itemId};
                  if (action.contains('View')) {
                    path = (itemObj is SupplyEntity)
                        ? RoutingConstants.nestedViewSupplyItemRoutePath
                        : RoutingConstants.nestedViewInventoryItemRoutePath;
                  }
                  if (action.contains('Edit')) {
                    path = (itemObj is SupplyEntity)
                        ? RoutingConstants.nestedUpdateSupplyItemViewRoutePath
                        : RoutingConstants
                            .nestedUpdateInventoryItemViewRoutePath;
                  }
                  context.go(path!, extra: extras);
                },
              ),
            ),
            if (_isLoading)
              LinearProgressIndicator(
                  backgroundColor: Theme.of(context).dividerColor,
                  color: AppColor.accent),
            if (_errorMessage != null)
              Center(child: CustomMessageBox.error(message: _errorMessage!)),
            const SizedBox(height: 10.0),
            PaginationControls(
              currentPage: _currentPage,
              totalRecords: _totalRecords,
              pageSize: _pageSize,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
                _fetchItems();
              },
              onPageSizeChanged: (size) {
                setState(() {
                  _pageSize = size;
                });
                _fetchItems();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_selectedItemIds.isNotEmpty) ...[
          Text('${_selectedItemIds.length} selected'),
          const SizedBox(width: 10),
          CustomOutlineButton(
            onTap: () => setState(() {
              _selectedItemIds.clear();
              _preselectedItems.clear();
              for (var row in _tableRows) {
                row.isSelected = false;
              }
            }),
            text: 'Clear Selection',
            width: 150.0,
          ),
          const SizedBox(width: 10),
        ],
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
        const SizedBox(width: 10),
        CustomFilledButton(
          onTap: () {
            final selectedItems = _preselectedItems
                .where((item) => _selectedItemIds.contains(
                    item['shareable_item_information']['base_item_id']
                        .toString()))
                .toList();
            widget.onSelectedItems(selectedItems);
            context.pop();
          },
          text: 'Add',
          width: 180.0,
          height: 40.0,
        ),
      ],
    );
  }
}
