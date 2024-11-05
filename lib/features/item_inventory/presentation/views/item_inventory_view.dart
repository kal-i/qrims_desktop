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

class ItemInventoryView extends StatefulWidget {
  const ItemInventoryView({super.key});

  @override
  State<ItemInventoryView> createState() => _ItemInventoryViewState();
}

class _ItemInventoryViewState extends State<ItemInventoryView> {
  late ItemInventoryBloc _itemInventoryBloc;
  late ItemSuggestionsService _itemSuggestionsService;
  late String _selectedSortValue = 'acquired_date';
  late AssetClassification? _selectedClassificationFilter;
  late AssetSubClass? _selectedSubClassFilter;

  final _manufacturerController = TextEditingController();
  final _brandController = TextEditingController();
  final _assetClassificationController = TextEditingController();
  final _assetSubClassController = TextEditingController();

  final ValueNotifier<String?> _selectedManufacturer = ValueNotifier(null);

  final ValueNotifier<String> _selectedSortOrder = ValueNotifier('Descending');
  final ValueNotifier<String> _selectedFilterNotifier =
      ValueNotifier('in_stock');

  final ValueNotifier<int> _totalItemsCount = ValueNotifier(0);
  final ValueNotifier<int> _inStockCount = ValueNotifier(0);
  final ValueNotifier<int> _lowStockCount = ValueNotifier(0);
  final ValueNotifier<int> _outOfStockCount = ValueNotifier(0);

  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _denounce;

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

  final ValueNotifier<bool> _isFilterModalVisible = ValueNotifier(false);
  final ValueNotifier<bool> _isSortModalVisible = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _itemInventoryBloc = context.read<ItemInventoryBloc>();
    _itemSuggestionsService = serviceLocator<ItemSuggestionsService>();

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
        manufacturerName: _manufacturerController.text,
        brandName: _brandController.text,
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

    _selectedManufacturer.value = null;
    _manufacturerController.clear();
    _brandController.clear();
    _assetClassificationController.clear();
    _assetSubClassController.clear();

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
    if (_denounce?.isActive ?? false) _denounce?.cancel();
    _denounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchItems();
    });
  }

  List<String> _assetClassificationSuggestionCallback(
      String? assetClassification) {
    final assetClassifications = AssetClassification.values
        .map((classification) => readableEnumConverter(classification))
        .toList();

    if (assetClassification != null && assetClassification.isNotEmpty) {
      final filteredClassifications =
          assetClassifications.where((classification) {
        return classification
            .toLowerCase()
            .contains(assetClassification.toLowerCase());
      }).toList();

      return filteredClassifications;
    }
    return assetClassifications;
  }

  List<String> _assetSubClassSuggestionCallback(String? assetSubClass) {
    final assetSubClasses = AssetSubClass.values
        .map((subClass) => readableEnumConverter(subClass))
        .toList();

    if (assetSubClass != null && assetSubClass.isNotEmpty) {
      final filteredSubClass = assetSubClasses.where((subClass) {
        return subClass.toLowerCase().contains(assetSubClass.toLowerCase());
      }).toList();

      return filteredSubClass;
    }
    return assetSubClasses;
  }

  void _onAssetClassificationSelected(String value) {
    _assetClassificationController.text = value;
    _selectedClassificationFilter = AssetClassification.values.firstWhere(
        (assetClassification) =>
            readableEnumConverter(assetClassification) == value);
  }

  void _onAssetSubClassSelected(String value) {
    _assetSubClassController.text = value;
    _selectedSubClassFilter = AssetSubClass.values.firstWhere(
        (assetSubClass) => readableEnumConverter(assetSubClass) == value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _denounce?.cancel();
    _selectedSortOrder.dispose();
    _selectedFilterNotifier.dispose();
    _totalItemsCount.dispose();

    _isFilterModalVisible.dispose();
    _isSortModalVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
        ),
        _buildFilterModal(),
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
            _buildSortButton(),
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
      onTap: () => _isFilterModalVisible.value = true,
      isOutlined: true,
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildSortButton() {
    return CustomIconButton(
      tooltip: 'Sort',
      onTap: () => _isSortModalVisible.value = true,
      isOutlined: true,
      icon: FluentIcons.text_sort_ascending_20_regular,
    );
  }

  // Widget _buildSortButton() {
  //   return ValueListenableBuilder(
  //       valueListenable: _selectedSortOrder,
  //       builder: (BuildContext context, String value, Widget? child) {
  //         return ReusablePopupMenuButton(
  //           onSelected: _onSortSelected,
  //           tooltip: 'Sort',
  //           icon: const CustomIconButton(
  //             icon: FluentIcons.text_sort_ascending_20_regular,
  //             isOutlined: true,
  //           ),
  //           popupMenuItems: _buildSortMenuItems(),
  //         );
  //       });
  // }

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
                        item.manufacturerBrandEntity.manufacturer.name,
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

  Widget _buildItemManufacturersSuggestionField() {
    return CustomSearchBox(
      suggestionsCallback: (manufacturerName) async {
        final manufacturerNames = await _itemSuggestionsService
            .fetchManufacturers(manufacturerName: manufacturerName);

        if (manufacturerNames == []) {
          _brandController.clear();
          _selectedManufacturer.value = '';
        }

        return manufacturerNames;
      },
      onSelected: (value) {
        _manufacturerController.text = value;
        _brandController.clear();
        _selectedManufacturer.value = value;
      },
      controller: _manufacturerController,
      label: 'Manufacturer',
    );
  }

  Widget _buildItemBrandsSuggestionField() {
    return ValueListenableBuilder(
      valueListenable: _selectedManufacturer,
      builder: (context, selectedManufacturer, child) {
        return CustomSearchBox(
          key: ValueKey(selectedManufacturer),
          suggestionsCallback: (brandName) async {
            if (selectedManufacturer != null &&
                selectedManufacturer.isNotEmpty) {
              final brandNames = await _itemSuggestionsService.fetchBrands(
                  manufacturerName: selectedManufacturer, brandName: brandName);

              return brandNames;
            } else {
              return Future.value([]);
            }
          },
          onSelected: (value) {
            _brandController.text = value;
          },
          controller: _brandController,
          label: 'Brand',
        );
      },
    );
  }

  Widget _buildAssetClassificationsSuggestionField() {
    return CustomSearchBox(
      suggestionsCallback: _assetClassificationSuggestionCallback,
      onSelected: _onAssetClassificationSelected,
      controller: _assetClassificationController,
      label: 'Asset Classification',
    );
  }

  Widget _buildAssetSubClassesSuggestionField() {
    return CustomSearchBox(
      suggestionsCallback: _assetSubClassSuggestionCallback,
      onSelected: _onAssetSubClassSelected,
      controller: _assetSubClassController,
      label: 'Asset Sub Class',
    );
  }

  Widget _buildFilterModal() {
    return ValueListenableBuilder(
      valueListenable: _isFilterModalVisible,
      builder: (context, isModalVisible, child) {
        return SlideableContainer(
          width: 400.0,
          content: isModalVisible
              ? _buildFilterModalContent()
              : const SizedBox.shrink(),
          isVisible: isModalVisible,
          onClose: () {
            _isFilterModalVisible.value = false;
          },
        );
      },
    );
  }

  Widget _buildFilterModalContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (context.watch<ThemeBloc>().state == AppTheme.light
                ? AppColor.lightSecondary
                : AppColor.darkSecondary),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                HugeIcons.strokeRoundedCancel01,
                size: 16.0,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const Text(
                //   'Manufacturer',
                //   style: TextStyle(
                //     fontFamily: 'Inter',
                //     fontSize: 12.0,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                // const SizedBox(
                //   height: 5.0,
                // ),
                _buildItemManufacturersSuggestionField(),
                // const SizedBox(
                //   height: 20.0,
                // ),
                // const Text(
                //   'Brand',
                //   style: TextStyle(
                //     fontFamily: 'Inter',
                //     fontSize: 12.0,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                const SizedBox(
                  height: 5.0,
                ),
                _buildItemBrandsSuggestionField(),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Asset Classification',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                _buildAssetClassificationsSuggestionField(),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Asset Sub Class',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                _buildAssetSubClassesSuggestionField(),
              ],
            ),
          ),
        ),
        _modalActionsRow(),
      ],
    );
  }

  Widget _modalActionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: CustomOutlineButton(
              onTap: () {
                _isFilterModalVisible.value = false;
              },
              height: 40.0,
              text: 'Cancel',
            ),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: CustomFilledButton(
              onTap: () {
                _fetchItems();
                _isFilterModalVisible.value = false;
              },
              height: 40.0,
              text: 'Apply',
            ),
          ),
        ],
      ),
    );
  }
}
