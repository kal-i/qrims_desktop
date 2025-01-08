import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/pagination_controls_2.dart';
import '../../data/models/inventory_summary.dart';
import '../../data/models/item.dart';
import '../../data/models/requested_item.dart';
import '../bloc/dashboard/inventory_summary/inventory_summary_bloc.dart';
import '../bloc/dashboard/low_stock/low_stock_bloc.dart';
import '../bloc/dashboard/requests_summary/requests_summary_bloc.dart';
import '../../../../core/common/components/kpi_card.dart';
import '../components/dashboard_kpi_card.dart';
import '../components/inventory_summary_pie_chart.dart';
import '../components/item_card.dart';
import '../components/most_requested_items_bar_graph.dart';
import '../components/stock_level_pie_chart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late InventorySummaryBloc _inventorySummaryBloc;
  late RequestsSummaryBloc _requestsSummaryBloc;
  late LowStockBloc _lowStockBloc;

  final ValueNotifier<int> _inStocksCount = ValueNotifier(0);
  final ValueNotifier<int> _lowStocksCount = ValueNotifier(0);
  final ValueNotifier<int> _outOfStocksCount = ValueNotifier(0);

  final ValueNotifier<int> _ongoingRequestsCount = ValueNotifier(0);
  final ValueNotifier<int> _fulfilledRequestsCount = ValueNotifier(0);

  final List<ItemModel> _lowStockItems = [];

  @override
  void initState() {
    super.initState();
    _inventorySummaryBloc = context.read<InventorySummaryBloc>();
    _requestsSummaryBloc = context.read<RequestsSummaryBloc>();
    _lowStockBloc = context.read<LowStockBloc>();
    _fetchInventorySummary();
    _fetchMostRequestedItems();
    //_fetchLowStockItems();
  }

  void _fetchInventorySummary() {
    _inventorySummaryBloc.add(GetInventorySummaryEvent());
  }

  void _fetchMostRequestedItems() {
    _requestsSummaryBloc.add(const GetMostRequestedItemsEvent());
  }

  void _fetchLowStockItems() {
    _lowStockBloc.add(const GetLowStockEvent(page: 1, pageSize: 10));
  }

  @override
  void dispose() {
    _inStocksCount.dispose();
    _lowStocksCount.dispose();
    _outOfStocksCount.dispose();
    _ongoingRequestsCount.dispose();
    _fulfilledRequestsCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildMainContentSection(),
            ),
            // const SizedBox(
            //   width: 20.0,
            // ),
            // Expanded(
            //   child: _buildSidePanelSection(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContentSection() {
    return Column(
      children: [
        _buildInventorySummarySection(),
        const SizedBox(
          height: 30.0,
        ),
        //_buildMostRequestedItemsSection(),
      ],
    );
  }

  Widget _buildInventorySummarySection() {
    return BlocListener<InventorySummaryBloc, InventorySummaryState>(
      listener: (context, state) {
        if (state is InventorySummaryLoaded) {
          _inStocksCount.value = state.inventorySummaryEntity.inStocksCount;
          _lowStocksCount.value = state.inventorySummaryEntity.lowStocksCount;
          _outOfStocksCount.value =
              state.inventorySummaryEntity.outOfStocksCount;
        }
      },
      child: BlocBuilder<InventorySummaryBloc, InventorySummaryState>(
          builder: (context, state) {
        return Column(
          children: [
            _buildCardsSection(),
            const SizedBox(
              height: 30.0,
            ),
            if (state is InventorySummaryLoaded)
              Row(
                children: [
                  Expanded(
                      child: StockLevelPieChart(
                    inStocksCount: state.inventorySummaryEntity.inStocksCount,
                    lowStocksCount: state.inventorySummaryEntity.lowStocksCount,
                    outOfStocksCount:
                        state.inventorySummaryEntity.outOfStocksCount,
                  )),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: InventorySummaryPieChart(
                      inventoryData:
                          state.inventorySummaryEntity as InventorySummaryModel,
                    ),
                  ),
                ],
              ),
            if (state is InventorySummaryLoading)
              Row(
                children: [
                  Expanded(
                    child: BaseContainer(
                      child: Column(
                        children: [
                          Text(
                            'Loading graph...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                          ),
                          const SpinKitFadingCircle(
                            color: AppColor.accent,
                            size: 50.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: BaseContainer(
                      child: Column(
                        children: [
                          Text(
                            'Loading graph...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                          ),
                          const SpinKitFadingCircle(
                            color: AppColor.accent,
                            size: 50.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
    //cdreturn ;
  }

  Widget _buildMostRequestedItemsSection() {
    return BlocListener<RequestsSummaryBloc, RequestsSummaryState>(
        listener: (context, state) {
      if (state is RequestsSummaryLoaded) {
        _ongoingRequestsCount.value =
            state.requestsSummaryEntity.ongoingRequestCount;
        _fulfilledRequestsCount.value =
            state.requestsSummaryEntity.fulfilledRequestCount;
      }
    }, child: BlocBuilder<RequestsSummaryBloc, RequestsSummaryState>(
      builder: (context, state) {
        if (state is RequestsSummaryLoaded) {
          return MostRequestedItemsBarChart(
            mostRequestedItems: state.requestsSummaryEntity.mostRequestedItems
                as List<RequestedItemModel>,
          );
        }

        return BaseContainer(
          child: Column(
            children: [
              Text(
                'Loading graph...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              const SpinKitFadingCircle(
                color: AppColor.accent,
                size: 50.0,
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildCardsSection() {
    return Row(
      children: [
        Expanded(
          child: DashboardKPICard(
            title: 'In Stocks',
            count: _inStocksCount.value,
            change: 4.8,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Out of Stocks',
            count: _outOfStocksCount.value,
            change: -1.8,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Ongoing Requests',
            count: _ongoingRequestsCount.value, // add pending and ongoing
            change: 5.8,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Fulfilled Requests',
            count: _fulfilledRequestsCount.value, // get fulfilled req count
            change: 5.8,
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySummaryChartsSection() {
    return Row();
  }

  Widget _buildSidePanelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseContainer(
          height: 500.0,
          color: Theme.of(context).primaryColor,
          child: _buildLowStockSection(),
        ),
        SizedBox(
          height: 20.0,
        ),
        BaseContainer(
          height: 400.0,
          color: Theme.of(context).primaryColor,
          child: _buildOutOfStockSection(),
        ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return BlocListener<LowStockBloc, LowStockState>(
      listener: (context, state) {
        if (state is LowStockLoaded) {
          _lowStockItems.clear();
          _lowStockItems
              .addAll(state.items.map((item) => item as ItemModel).toList());
        }
      },
      child: BlocBuilder<LowStockBloc, LowStockState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildLowStockHeader(),
              const SizedBox(
                height: 30.0,
              ),
              if (state is LowStockLoading)
                const SpinKitFadingCircle(
                  color: AppColor.accent,
                  size: 10.0,
                ),
              if (state is LowStockError)
                CustomMessageBox.error(
                  message: state.message,
                ),
              Expanded(
                child: _buildLowStockListView(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLowStockHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low Stock Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            PaginationControls2(
              currentPage: 1,
              totalRecords: 10,
              pageSize: 10,
              onPageChanged: (page) {
                // _currentPage = page;
                // _fetchNotifications();
              },
              onPageSizeChanged: (size) {
                // _pageSize = size;
                // _fetchNotifications();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutOfStockSection() {
    return BlocListener<LowStockBloc, LowStockState>(
      listener: (context, state) {
        if (state is LowStockLoaded) {
          _lowStockItems.clear();
          _lowStockItems
              .addAll(state.items.map((item) => item as ItemModel).toList());
        }
      },
      child: BlocBuilder<LowStockBloc, LowStockState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildOutOfStockHeader(),
              const SizedBox(
                height: 30.0,
              ),
              if (state is LowStockLoading)
                const SpinKitFadingCircle(
                  color: AppColor.accent,
                  size: 10.0,
                ),
              if (state is LowStockError)
                CustomMessageBox.error(
                  message: state.message,
                ),
              Expanded(
                child: _buildLowStockListView(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOutOfStockHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Out of Stock Items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            PaginationControls2(
              currentPage: 1,
              totalRecords: 10,
              pageSize: 10,
              onPageChanged: (page) {
                // _currentPage = page;
                // _fetchNotifications();
              },
              onPageSizeChanged: (size) {
                // _pageSize = size;
                // _fetchNotifications();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLowStockListView() {
    return RefreshIndicator(
      color: AppColor.accent,
      onRefresh: () async {},
      child: ListView.builder(
        itemCount: _lowStockItems.length,
        itemBuilder: (context, index) => ItemCard(
          item: _lowStockItems[index],
        ),
      ),
    );
  }

  Widget _buildInventorySummaryCardsSection() {
    return Row(
      children: [
        Expanded(
          child: KPICard(
            icon: HugeIcons.strokeRoundedPackageAdd,
            title: 'In Stocks',
            data: _inStocksCount.value.toString(),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: KPICard(
            icon: HugeIcons.strokeRoundedPackageProcess,
            title: 'Low Stocks',
            data: _lowStocksCount.value.toString(),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: KPICard(
            icon: HugeIcons.strokeRoundedPackageRemove,
            title: 'Out of Stocks',
            data: _outOfStocksCount.value.toString(),
          ),
        ),
      ],
    );
  }

  // Row(
  // children: [
  // /// left
  // Expanded(
  // flex: 5,
  // child: Column(
  // children: [
  // /// KPI Overview
  // _buildInventorySummaryCardsSection(),
  //
  // const SizedBox(
  // height: 10.0,
  // ),
  //
  // /// Inventory Overview
  // Expanded(
  // child: Row(
  // children: [
  // Expanded(child: _buildCategoricalInventoryDataSection()),
  // const SizedBox(
  // width: 10.0,
  // ),
  // Expanded(child: _buildCategoricalInventoryDataSection()),
  // ],
  // ),
  // ),
  //
  // const SizedBox(
  // height: 10.0,
  // ),
  //
  // /// In-demand Items Overview
  // Expanded(
  // child: BaseContainer(
  // child: Column(
  // children: [
  // Row(
  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  // children: [
  // Text(
  // 'In-demand Overview',
  // style: Theme.of(context).textTheme.titleSmall,
  // ),
  // ],
  // ),
  // ],
  // ),
  // ),
  // ),
  // ],
  // ),
  // ),
  //
  // const SizedBox(
  // width: 10.0,
  // ),
  //
  // /// right
  // Expanded(
  // flex: 2,
  // child: Column(
  // children: [
  // /// Activity Overview
  // Expanded(
  // child: BaseContainer(
  // child: Column(
  // crossAxisAlignment: CrossAxisAlignment.stretch,
  // children: [
  // Text(
  // 'Recent Activity Logs',
  // style: Theme.of(context).textTheme.titleSmall,
  // ),
  // const Divider(),
  // Expanded(
  // child:
  // BlocBuilder<UserActivityBloc, UserActivityState>(
  // builder: (context, state) {
  // if (state is UserActivityLoading &&
  // state.isFirstFetch) {
  // return const Loader();
  // }
  //
  // final activities = state is UserActivityLoaded
  // ? state.userActivities
  //     : <UserActivityEntity>[];
  //
  // return NotificationListener<ScrollNotification>(
  // onNotification: (ScrollNotification scrollInfo) {
  // // if reached the scroll end and state is not loading, invoke fetch next page
  // if (scrollInfo.metrics.pixels ==
  // scrollInfo.metrics.maxScrollExtent &&
  // state is! UserActivityLoading) {
  // context.read<UserActivityBloc>().fetchNextPage(
  // 1); // todo: replace later using auth bloc builder to get user info
  // }
  // return false;
  // },
  // child: ListView.builder(
  // itemCount: activities.length +
  // (state is UserActivityLoading ? 1 : 0),
  // itemBuilder: (context, index) {
  // if (index < activities.length) {
  // final activity = activities[index];
  // return ActivityLogCard(
  // userActivityEntity: activity);
  // } else {
  // return const Loader();
  // }
  // },
  // ),
  // );
  // // return ListView(
  // //   // physics: const NeverScrollableScrollPhysics(), // this will disable the scrollable if fixed height
  // //   shrinkWrap: true,
  // //   children: const [
  // //     ActivityLogCard(),
  // //     ActivityLogCard(),
  // //     ActivityLogCard(),
  // //     ActivityLogCard(),
  // //     ActivityLogCard(),
  // //   ],
  // // );
  // }),
  // ),
  // ],
  // ),
  // ),
  // ),
  //
  // const SizedBox(
  // height: 10.0,
  // ),
  //
  // /// Limited Items Overview
  // Expanded(
  // child: BaseContainer(
  // child: Column(
  // crossAxisAlignment: CrossAxisAlignment.stretch,
  // children: [
  // Text(
  // 'Running Out of Stocks',
  // style: Theme.of(context).textTheme.titleSmall,
  // ),
  // const Divider(),
  // Expanded(
  // child: ListView(
  // // physics: const NeverScrollableScrollPhysics(),
  // shrinkWrap: true,
  // children: const [
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // LimitedItemCard(),
  // ],
  // ),
  // ),
  // ],
  // ),
  // ),
  // ),
  // ],
  // ),
  // ),
  // ],
  // ),
}
