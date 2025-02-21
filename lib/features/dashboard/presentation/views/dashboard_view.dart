import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/pagination_controls_2.dart';
import '../../domain/entities/fulfilled_request_trend.dart';
import '../../domain/entities/inventory_stock.dart';
import '../../domain/entities/most_requested_item.dart';
import '../../domain/entities/reusable_item_information.dart';
import '../bloc/dashboard/inventory_summary/inventory_summary_bloc.dart';
import '../bloc/dashboard/low_stock/low_stock_bloc.dart';
import '../bloc/dashboard/out_of_stock/out_of_stock_bloc.dart';
import '../bloc/dashboard/requests_summary/requests_summary_bloc.dart';
import '../components/chart_container.dart';
import '../components/dashboard_kpi_card.dart';
import '../components/fulfilled_request_over_time_line_chart.dart';
import '../components/inventory_stock_pie_chart.dart';
import '../components/most_requested_items_bar_chart.dart';
import '../components/reusable_item_information_container.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late InventorySummaryBloc _inventorySummaryBloc;
  late RequestsSummaryBloc _requestsSummaryBloc;
  late LowStockBloc _lowStockBloc;
  late OutOfStockBloc _outOfStockBloc;

  final ValueNotifier<List<int>> _suppliesTrends = ValueNotifier([]);
  final ValueNotifier<List<int>> _equipmentTrends = ValueNotifier([]);
  final ValueNotifier<int> _suppliesCount = ValueNotifier(0);
  final ValueNotifier<int> _equipmentCount = ValueNotifier(0);
  final ValueNotifier<double> _supplyPercentageChange = ValueNotifier(0.0);
  final ValueNotifier<double> _equipmentPercentageChange = ValueNotifier(0.0);

  final ValueNotifier<int> _ongoingRequestsCount = ValueNotifier(0);
  final ValueNotifier<int> _fulfilledRequestsCount = ValueNotifier(0);
  final ValueNotifier<List<int>> _ongoingRequestsTrends = ValueNotifier([]);
  final ValueNotifier<List<int>> _fulfilledRequestsTrends = ValueNotifier([]);
  final ValueNotifier<double> _ongoingPercentageChange = ValueNotifier(0.0);
  final ValueNotifier<double> _fulfilledPercentageChange = ValueNotifier(0.0);

  final ValueNotifier<List<InventoryStockEntity>> _inventoryStocks =
      ValueNotifier([]);
  final ValueNotifier<List<MostRequestedItemEntity>> _mostRequestedItems =
      ValueNotifier([]);
  final ValueNotifier<List<FulfilledRequestTrendEntity>>
      _fulfilledRequestTrendEntities = ValueNotifier([]);

  final ValueNotifier<List<ReusableItemInformationEntity>>
      _lowStockItemEntities = ValueNotifier([]);
  final ValueNotifier<List<ReusableItemInformationEntity>>
      _outOfStockItemEntities = ValueNotifier([]);

  int _lowStockCurrentPage = 1;
  int _lowStockPageSize = 5;
  int _lowStockTotalRecords = 0;

  int _outOfStockCurrentPage = 1;
  int _outOfStockPageSize = 5;
  int _outOfStockTotalRecords = 0;

  @override
  void initState() {
    super.initState();
    _inventorySummaryBloc = context.read<InventorySummaryBloc>();
    _requestsSummaryBloc = context.read<RequestsSummaryBloc>();
    _lowStockBloc = context.read<LowStockBloc>();
    _outOfStockBloc = context.read<OutOfStockBloc>();

    _fetchInventorySummary();
    _fetchRequestsSummary();
    _fetchLowStockItems();
    _fetchOutOfStockItems();
  }

  void _fetchInventorySummary() {
    _inventorySummaryBloc.add(
      GetInventorySummaryEvent(),
    );
  }

  void _fetchRequestsSummary() {
    _requestsSummaryBloc.add(
      GetRequestsSummaryEvent(),
    );
  }

  void _fetchLowStockItems() {
    _lowStockBloc.add(
      GetLowStockEvent(
        page: _lowStockCurrentPage,
        pageSize: _lowStockPageSize,
      ),
    );
  }

  void _fetchOutOfStockItems() {
    _outOfStockBloc.add(
      GetOutOfStockEvent(
        page: _outOfStockCurrentPage,
        pageSize: _outOfStockPageSize,
      ),
    );
  }

  @override
  void dispose() {
    _suppliesCount.dispose();
    _equipmentCount.dispose();
    _ongoingRequestsCount.dispose();
    _fulfilledRequestsCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<InventorySummaryBloc, InventorySummaryState>(
            listener: (context, state) {
              if (state is InventorySummaryLoaded) {
                _suppliesCount.value =
                    state.inventorySummaryEntity.suppliesCount;
                _equipmentCount.value =
                    state.inventorySummaryEntity.equipmentCount;

                _suppliesTrends.value = state
                    .inventorySummaryEntity.supplyWeeklyTrendEntities
                    .map((e) => e.totalQuantity)
                    .toList();
                _equipmentTrends.value = state
                    .inventorySummaryEntity.equipmentWeeklyTrendEntities
                    .map((e) => e.totalQuantity)
                    .toList();

                _supplyPercentageChange.value =
                    state.inventorySummaryEntity.supplyPercentageChange;
                _equipmentPercentageChange.value =
                    state.inventorySummaryEntity.equipmentPercentageChange;

                _inventoryStocks.value =
                    state.inventorySummaryEntity.inventoryStocks;
              }
            },
          ),
          BlocListener<RequestsSummaryBloc, RequestsSummaryState>(
            listener: (context, state) {
              if (state is RequestsSummaryLoaded) {
                _ongoingRequestsCount.value =
                    state.requestsSummaryEntity.ongoingRequestCount;
                _fulfilledRequestsCount.value =
                    state.requestsSummaryEntity.fulfilledRequestCount;

                _ongoingRequestsTrends.value = state
                    .requestsSummaryEntity.ongoingWeeklyTrendEntities
                    .map((e) => e.requestCount)
                    .toList();
                _fulfilledRequestsTrends.value = state
                    .requestsSummaryEntity.fulfilledWeeklyTrendEntities
                    .map((e) => e.requestCount)
                    .toList();

                _ongoingPercentageChange.value =
                    state.requestsSummaryEntity.ongoingPercentageChange;
                _fulfilledPercentageChange.value =
                    state.requestsSummaryEntity.fulfilledPercentageChange;

                _mostRequestedItems.value =
                    state.requestsSummaryEntity.mostRequestedItemEntities;

                _fulfilledRequestTrendEntities.value =
                    state.requestsSummaryEntity.fulfilledRequestTrendEntities;
              }
            },
          ),
          BlocListener<LowStockBloc, LowStockState>(
            listener: (context, state) {
              if (state is LowStockLoaded) {
                _lowStockItemEntities.value = state.items;
              }
            },
          ),
          BlocListener<OutOfStockBloc, OutOfStockState>(
            listener: (context, state) {
              if (state is OutOfStocksLoaded) {
                _outOfStockItemEntities.value = state.items;
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInventorySummarySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySummarySection() {
    return BlocBuilder<InventorySummaryBloc, InventorySummaryState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildCardsSection(),
            const SizedBox(
              height: 30.0,
            ),
            _buildGraphicalChartsSection(),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildRunningOutOfStocksSection(),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: _buildOutOfStocksSection(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardsSection() {
    return Row(
      children: [
        Expanded(
          child: DashboardKPICard(
            title: 'Supplies',
            count: _suppliesCount.value,
            change: _supplyPercentageChange.value,
            weeklyTrends: _suppliesTrends.value,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Equipment',
            count: _equipmentCount.value,
            change: _equipmentPercentageChange.value,
            weeklyTrends: _equipmentTrends.value,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Ongoing Requests',
            count: _ongoingRequestsCount.value,
            change: _ongoingPercentageChange.value,
            weeklyTrends: _ongoingRequestsTrends.value,
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: DashboardKPICard(
            title: 'Fulfilled Requests',
            count: _fulfilledRequestsCount.value,
            change: _fulfilledPercentageChange.value,
            weeklyTrends: _fulfilledRequestsTrends.value,
          ),
        ),
      ],
    );
  }

  Widget _buildGraphicalChartsSection() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _fulfilledRequestTrendEntities,
            builder: (context, fulfilledRequestTrendEntities, child) {
              return FulfilledRequestOverTimeLineChart(
                fulfilledRequestTrendEntities: fulfilledRequestTrendEntities,
              );
            },
          ),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _mostRequestedItems,
              builder: (context, mostRequestedItems, child) {
                return MostRequestedItemsBarChart(
                  mostRequestedItemEntities: mostRequestedItems,
                );
              }),
        ),
        const SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: ValueListenableBuilder(
              valueListenable: _inventoryStocks,
              builder: (context, inventoryStocks, child) {
                return InventoryStockPieChart(
                  inventoryStocks: inventoryStocks,
                );
              }),
        ),
      ],
    );
  }

  Widget _buildRunningOutOfStocksSection() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        return ChartContainer(
          title: 'Running-out-of-stocks',
          description:
              'Supply items that reached the defined inventory threshold (quantity below 10).',
          action: PaginationControls2(
            currentPage: _lowStockCurrentPage,
            totalRecords: _lowStockTotalRecords,
            pageSize: _lowStockPageSize,
            onPageChanged: (page) {
              _lowStockCurrentPage = page;
              _fetchLowStockItems();
            },
            onPageSizeChanged: (size) {
              _lowStockPageSize = size;
              _fetchLowStockItems();
            },
          ),
          child: ListView.builder(
            itemCount: _lowStockItemEntities.value.length,
            itemBuilder: (context, index) {
              return ReusableItemInformationContainer(
                reusableItemInformationEntity:
                    _lowStockItemEntities.value[index],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOutOfStocksSection() {
    return BlocBuilder<OutOfStockBloc, OutOfStockState>(
      builder: (context, state) {
        return ChartContainer(
          title: 'Out-of-stocks',
          description: 'Supply items that have reached a quantity of 0.',
          action: PaginationControls2(
            currentPage: _outOfStockCurrentPage,
            totalRecords: _outOfStockTotalRecords,
            pageSize: _outOfStockPageSize,
            onPageChanged: (page) {
              _outOfStockCurrentPage = page;
              _fetchOutOfStockItems();
            },
            onPageSizeChanged: (size) {
              _outOfStockPageSize = size;
              _fetchOutOfStockItems();
            },
          ),
          child: ListView.builder(
            itemCount: _outOfStockItemEntities.value.length,
            itemBuilder: (context, index) {
              return ReusableItemInformationContainer(
                reusableItemInformationEntity:
                    _outOfStockItemEntities.value[index],
              );
            },
          ),
        );
      },
    );
  }
}
