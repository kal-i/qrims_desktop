import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/themes/app_color.dart';

import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';

import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/enums/role.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/fund_cluster_to_readable_string.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/supply.dart';
import '../bloc/item_inventory_bloc.dart';
import '../components/filter_item_modal.dart';
import '../components/register_new_item_modal.dart';

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
  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('');

  final ValueNotifier<int> _totalItemsCount = ValueNotifier(0);
  final ValueNotifier<int> _suppliesCount = ValueNotifier(0);
  final ValueNotifier<int> _inventoryCount = ValueNotifier(0);
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
    'Unit',
    'Quantity',
    'Unit Cost',
    'Date Acquired',
    'Fund Cluster',
  ];
  late List<TableData> _tableRows;

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

    _tableRows = [];
    _initializeTableConfig();
    _fetchItems();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        1,
        3,
        1,
        1,
        1,
        1,
        1,
      ],
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

    _selectedFilterNotifier.value = '';
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
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      bool isAdmin = false;

      if (state is AuthSuccess) {
        isAdmin = SupplyDepartmentEmployeeModel.fromEntity(state.data).role ==
            Role.admin;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          _buildHeaderRow(isAdmin),
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
            child: _buildDataTable(isAdmin),
          ),
        ],
      );
    });
  }

  Widget _buildHeaderRow(bool isAdmin) {
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
            if (isAdmin)
              const CustomMessageBox.info(
                message: 'You can only view.',
              )
            else
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
                  // baseColor: Colors.transparent,
                );
              }),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _suppliesCount,
              builder: (context, suppliesCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageDelivered,
                  title: 'Supply Items',
                  data: suppliesCount.toString(),
                  // baseColor: Colors.transparent,
                );
              }),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _inventoryCount,
              builder: (context, inventoryCount, child) {
                return KPICard(
                  icon: HugeIcons.strokeRoundedPackageProcess,
                  title: 'Inventory Items',
                  data: inventoryCount.toString(),
                  // baseColor: Colors.transparent,
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
                  //baseColor: Colors.transparent,
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
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'View All': '',
      'Supply': 'supply',
      'Inventory': 'inventory',
      'Out': 'out',
    };
    return FilterTableRow(
      selectedFilterNotifier: _selectedFilterNotifier,
      filterMapping: filterMapping,
    );
  }

  Widget _buildRegisterButton() {
    return CustomFilledButton(
      width: 160.0,
      height: 40.0,
      onTap: () => showDialog(
        context: context,
        builder: (context) => RegisterNewItemModal(),
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
          onApplyFilters: (
            String? manufacturer,
            String? brand,
            AssetClassification? classification,
            AssetSubClass? subClass,
          ) {
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

  Widget _buildDataTable(bool isAdmin) {
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
          print(_totalRecords);
          _suppliesCount.value = state.suppliesCount;
          _inventoryCount.value = state.inventoryCount;
          _outOfStockCount.value = state.outOfStockCount;
          _totalItemsCount.value = _suppliesCount.value +
              _inventoryCount.value +
              _outOfStockCount.value;
          _tableRows.clear();
          _tableRows.addAll(
            state.items
                .map(
                  (item) => TableData(
                    id: item.shareableItemInformationEntity.id,
                    object: item,
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
                        (item.shareableItemInformationEntity.specification ==
                                    null ||
                                item.shareableItemInformationEntity
                                        .specification
                                        ?.toLowerCase() ==
                                    'na' ||
                                item.shareableItemInformationEntity
                                        .specification
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
                      ),
                      Text(
                        readableEnumConverter(
                          item.shareableItemInformationEntity.unit,
                        ),
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
                        formatCurrency(
                          item.shareableItemInformationEntity.unitCost,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        documentDateFormatter(
                          item.shareableItemInformationEntity.acquiredDate!,
                        ),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        item.shareableItemInformationEntity.fundCluster
                                ?.toReadableString() ??
                            'Not Specified.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                    menuItems: [
                      {'text': 'View', 'icon': FluentIcons.eye_12_regular},
                      if (!isAdmin && _selectedFilterNotifier.value != 'out')
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
}
