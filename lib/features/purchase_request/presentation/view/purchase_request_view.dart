import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/app_routing_constants.dart';
import '../../../../config/sizing/sizing_config.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/filter_table_row.dart';
import '../../../../core/common/components/highlight_status_container.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/components/custom_container.dart';
import '../bloc/purchase_requests_bloc.dart';

class PurchaseRequestView extends StatefulWidget {
  const PurchaseRequestView({super.key});

  @override
  State<PurchaseRequestView> createState() => _PurchaseRequestViewState();
}

class _PurchaseRequestViewState extends State<PurchaseRequestView> {
  late PurchaseRequestsBloc _purchaseRequestsBloc;

  //final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _searchDelay = const Duration(milliseconds: 500);
  Timer? _denounce;

  final ValueNotifier<String> _selectedFilterNotifier =
      ValueNotifier('pending');

  int _currentPage = 1;
  int _pageSize = 10;
  int _totalRecords = 0;

  bool _isLoading = false;
  String? _errorMessage;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'PR No.',
    'Requesting Officer',
    'Date',
    'Status',
  ];
  late List<TableData> _tableRows = [];

  @override
  void initState() {
    super.initState();
    _purchaseRequestsBloc = context.read<PurchaseRequestsBloc>();
    _searchController.addListener(_onSearchChanged);
    _initializeTableConfig();
    _fetchPurchaseRequests();
    //_scrollController.addListener(_loadMoreData);
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [2, 2, 2, 2],
    );
  }

  void _fetchPurchaseRequests() {
    _purchaseRequestsBloc.add(
      GetPurchaseRequestsEvent(
        page: _currentPage,
        pageSize: _pageSize,
        prId: _searchController.text,
        // unitCost: unitCost,
        // date: date,
        // prStatus: prStatus,
        // isArchived: isArchived,
      ),
    );
  }

  void _refreshPurchaseRequestList() {
    _searchController.clear();
    _currentPage = 1;

    _selectedFilterNotifier.value = 'pending';
    _fetchPurchaseRequests();
  }

  void _onFilterChanged() {
    _searchController.clear();
    _currentPage = 1;
    _fetchPurchaseRequests();
  }

  void _onSearchChanged() {
    if (_denounce?.isActive ?? false) _denounce?.cancel();
    _denounce = Timer(_searchDelay, () {
      _currentPage = 1;
      _fetchPurchaseRequests();
    });
  }

  // Future<void> _loadMoreData() async {
  //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //     _isLoading = true;
  //     _currentPage++;
  //     _fetchPurchaseRequests();
  //   }
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _denounce?.cancel();

    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          height: 20.0,
        ),
        _buildTableRelatedActionsRow(),
        const SizedBox(
          height: 50.0,
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
            _buildKPIFilterSelection(),
            const SizedBox(
              width: 10.0,
            ),
            _buildRegisterButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildKPIFilterSelection() {
    return CustomDropdownField(
      onChanged: (value) {},
    );
  }

  final ValueNotifier<int> _pendingPurchaseRequestsCount = ValueNotifier(0);
  final ValueNotifier<int> _semiFulfilledPurchaseRequestsCount =
      ValueNotifier(0);
  final ValueNotifier<int> _fulfilledPurchaseRequestsCount = ValueNotifier(0);
  final ValueNotifier<int> _cancelledPurchaseRequestsCount = ValueNotifier(0);

  Widget _purchaseRequestKPICard() {
    return BaseContainer(
      padding: 20.0,
      height: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Requests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  '359',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                const Icon(
                  HugeIcons.strokeRoundedTradeUp,
                  color: AppColor.green,
                  size: 24.0,
                ),
                Text(
                  '+2.5%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          Text(
            'There has been a 15% increase in pending purchase requests this month.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: SizingConfig.textMultiplier * 1.5,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  // You have
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _pendingPurchaseRequestsCount,
            builder: (context, pendingPurchaseRequestsCount, child) {
              return _purchaseRequestKPICard();
            },
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _pendingPurchaseRequestsCount,
            builder: (context, pendingPurchaseRequestsCount, child) {
              return _purchaseRequestKPICard();
            },
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _pendingPurchaseRequestsCount,
            builder: (context, pendingPurchaseRequestsCount, child) {
              return _purchaseRequestKPICard();
            },
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _pendingPurchaseRequestsCount,
            builder: (context, pendingPurchaseRequestsCount, child) {
              return _purchaseRequestKPICard();
            },
          ),
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

  Widget _buildDataTable() {
    return BlocConsumer<PurchaseRequestsBloc, PurchaseRequestsState>(
      listener: (context, state) {
        if (state is PurchaseRequestsLoading) {
          _isLoading = true;
          _errorMessage = null;
        }

        if (state is PurchaseRequestsLoaded) {
          _isLoading = false;
          _totalRecords = state.totalPurchaseRequestsCount;
          _tableRows.clear();
          _tableRows.addAll(
            state.purchaseRequests.map(
              (purchaseRequest) => TableData(
                id: purchaseRequest.id,
                columns: [
                  Text(
                    purchaseRequest.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  Text(
                    capitalizeWord(
                        purchaseRequest.requestingOfficerEntity.name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  Text(
                    dateFormatter(purchaseRequest.date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  SizedBox(
                    width: 50.0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _buildStatusHighlighter(
                        purchaseRequest.purchaseRequestStatus,
                      ),
                    ),
                  ),
                ],
                menuItems: [],
              ),
            ),
          );
        }

        if (state is PurchaseRequestsError) {
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
                      onActionSelected: (index, action) {},
                    ),

                    // GridView.builder(
                    //   padding: EdgeInsets.all(10.0),
                    //   controller: _scrollController,
                    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 3, // no. of items in each row
                    //     mainAxisSpacing: 8.0, // space between rows
                    //     crossAxisSpacing: 8.0, // space between columns
                    //   ),
                    //   itemCount: _pr.length,
                    //   itemBuilder: (context, index) {
                    //     return _purchaseRequestCard();
                    //   },
                    // ),
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
                _fetchPurchaseRequests();
              },
              onPageSizeChanged: (size) {
                _pageSize = size;
                _fetchPurchaseRequests();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterTableRow() {
    final Map<String, String> filterMapping = {
      'Pending': 'pending',
      'Partially Fulfilled': 'low',
      'Fulfilled': 'out',
      'Cancelled': 'out',
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
      height: 40.0,
      onTap: () => context.go(
        '${RoutingConstants.purchaseRequestViewRoutePath}/${RoutingConstants.registerPurchaseRequestViewRoutePath}',
      ),
      text: 'Register Item',
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(
      onTap: _refreshPurchaseRequestList,
    );
  }

  Widget _buildFilterButton() {
    return const CustomIconButton(
      tooltip: 'Filter',
      //onTap: () => _isFilterModalVisible.value = true,
      isOutlined: true,
      icon: FluentIcons.filter_add_20_regular,
    );
  }

  Widget _buildSortButton() {
    return const CustomIconButton(
      tooltip: 'Sort',
      //onTap: () => _isSortModalVisible.value = true,
      isOutlined: true,
      icon: FluentIcons.text_sort_ascending_20_regular,
    );
  }

  Widget _buildStatusHighlighter(PurchaseRequestStatus prStatus) {
    return HighlightStatusContainer(
      statusStyle: _prStatusStyler(prStatus: prStatus),
    );
  }

  StatusStyle _prStatusStyler({required PurchaseRequestStatus prStatus}) {
    switch (prStatus) {
      case PurchaseRequestStatus.pending:
        return StatusStyle.yellow(label: 'Pending');
      case PurchaseRequestStatus.partiallyFulfilled:
        return StatusStyle.blue(label: 'Semi-Fulfilled');
      case PurchaseRequestStatus.fulfilled:
        return StatusStyle.green(label: 'Fulfilled');
      case PurchaseRequestStatus.cancelled:
        return StatusStyle.red(label: 'Cancelled');
      default:
        throw Exception('Invalid Purchase Request Status');
    }
  }

  // req. off.
  // pr no.
  // status
  // date
  // Widget _purchaseRequestCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(20.0),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10.0),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColor.darkPrimary.withOpacity(0.25),
  //           blurRadius: 4.0,
  //           spreadRadius: 0.0,
  //           offset: const Offset(0.0, 4.0),
  //         )
  //       ],
  //       color: Theme.of(context).cardColor,
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             RichText(
  //               text: TextSpan(
  //                 text: 'PR #',
  //                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                       fontSize: 24.0,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                 children: [
  //                   TextSpan(
  //                     text: '2024-10-012',
  //                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //                           fontSize: 24.0,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             IconButton(
  //               onPressed: () {},
  //               icon: const Icon(
  //                 HugeIcons.strokeRoundedMoreVertical,
  //                 size: 20.0,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(
  //           height: 10.0,
  //         ),
  //         Text(
  //           '13/10/2024',
  //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //                 fontSize: 13.0,
  //                 fontWeight: FontWeight.w400,
  //               ),
  //         ),
  //         const SizedBox(
  //           height: 10.0,
  //         ),
  //         HighlightStatusContainer(
  //           statusStyle: StatusStyle.yellow(
  //             label: 'Pending',
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
