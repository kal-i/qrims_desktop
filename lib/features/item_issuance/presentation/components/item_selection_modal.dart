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
import '../../../item_inventory/data/models/inventory_item.dart';
import '../../../item_inventory/data/models/supply.dart';
import '../../../item_inventory/domain/entities/inventory_item.dart';
import '../../../item_inventory/domain/entities/supply.dart';
import '../../../item_inventory/presentation/bloc/item_inventory_bloc.dart';

class ItemSelectionModal extends StatefulWidget {
  const ItemSelectionModal({
    super.key,
    required this.onSelectedItems,
    this.preselectedItems,
  });

  final Function(List<Map<String, dynamic>> selectedItems) onSelectedItems;
  final List<Map<String, dynamic>>? preselectedItems;

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
    //'Brand',
    //'Model',
    'Quantity',
    'Unit Cost',
  ];
  late List<TableData> _tableRows;

  @override
  void initState() {
    super.initState();
    _itemInventoryBloc = context.read<ItemInventoryBloc>();

    _preselectedItems = widget.preselectedItems ?? [];

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
          Expanded(
            child: _buildDataTable(),
          ),
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
          children: [
            ExpandableSearchButton(
              controller: _searchController,
            ),
            const SizedBox(
              width: 10.0,
            ),
            _buildRefreshButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      //'View All': '',
      'Supply': 'supply',
      'Equipment': 'equipment',
    };
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(
      onTap: _refreshItemList,
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
        if (state is SupplyItemRegistered ||
            state is InventoryItemRegistered ||
            state is ItemUpdated) {
          _isLoading = false;
          _refreshItemList();
        }

        if (state is ItemsLoaded) {
          _isLoading = false;
          _totalRecords = state.totalItemCount;
          _tableRows.clear();

          print('preselected items: ${widget.preselectedItems}');

          final selectedItemIds = (widget.preselectedItems ?? [])
              .map((item) => item['shareable_item_information']['base_item_id'])
              .toSet();

          _tableRows.addAll(state.items.where((item) {
            return !selectedItemIds
                .contains(item.shareableItemInformationEntity.id);
          }).map((item) {
            return TableData(
              id: item.shareableItemInformationEntity.id,
              object: item,
              columns: [
                Text(
                  capitalizeWord(item.productStockEntity.productName.name),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  (item.shareableItemInformationEntity.specification == null ||
                          item.shareableItemInformationEntity.specification
                                  ?.toLowerCase() ==
                              'n/a')
                      ? capitalizeWord(item.productStockEntity
                              .productDescription?.description ??
                          '')
                      : capitalizeWord(
                          '${item.productStockEntity.productDescription?.description}, ${item.shareableItemInformationEntity.specification}'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.shareableItemInformationEntity.quantity.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  item.shareableItemInformationEntity.unitCost.toString(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
              menuItems: [
                {
                  'text': 'View',
                  'icon': FluentIcons.eye_12_regular,
                },
              ],
            );
          }).toList());
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
                      onRowSelected: (index) {
                        final itemObj = _tableRows[index].object;

                        _preselectedItems.add(
                          itemObj is SupplyEntity
                              ? (itemObj as SupplyModel).toJson()
                              : (itemObj as InventoryItemModel).toJson(),
                        );

                        print('selected items to add: $_preselectedItems');
                      },
                      onActionSelected: (index, action) {
                        final itemId = _tableRows[index].id;
                        final itemObj = _tableRows[index].object;

                        String? path;
                        final Map<String, dynamic> extras = {
                          'item_id': itemId,
                        };

                        if (action.isNotEmpty) {
                          if (itemObj is SupplyEntity) {
                            if (action.contains('View')) {
                              extras['is_update'] = false;
                              path = RoutingConstants
                                  .nestedViewSupplyItemRoutePath;
                            }

                            if (action.contains('Edit')) {
                              extras['is_update'] = true;
                              path = RoutingConstants
                                  .nestedUpdateSupplyItemViewRoutePath;
                            }
                          }

                          if (itemObj is InventoryItemEntity) {
                            if (action.contains('View')) {
                              extras['is_update'] = false;
                              path = RoutingConstants
                                  .nestedViewInventoryItemRoutePath;
                            }

                            if (action.contains('Edit')) {
                              extras['is_update'] = true;
                              path = RoutingConstants
                                  .nestedUpdateInventoryItemViewRoutePath;
                            }
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

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: () {
            print('Sending to main view: $_preselectedItems');
            widget.onSelectedItems(
              _preselectedItems,
            );
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
