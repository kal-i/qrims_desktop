import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../domain/entities/most_requested_item.dart';
import 'chart_container.dart';

class MostRequestedItemsBarChart extends StatefulWidget {
  final List<MostRequestedItemEntity> mostRequestedItemEntities;

  const MostRequestedItemsBarChart({
    super.key,
    required this.mostRequestedItemEntities,
  });

  @override
  State<MostRequestedItemsBarChart> createState() =>
      _MostRequestedItemsBarChartState();
}

class _MostRequestedItemsBarChartState
    extends State<MostRequestedItemsBarChart> {
  int touchedIndex = -1;

  // Default data to display when the list is empty
  List<MostRequestedItemEntity> get _effectiveData {
    if (widget.mostRequestedItemEntities.isEmpty) {
      return List.generate(
        5, // Number of default bars
        (index) => MostRequestedItemEntity(
          productName: 'Item ${index + 1}',
          requestCount: 1, // Set a minimum value (e.g., 1) to make bars visible
        ),
      );
    }
    return widget.mostRequestedItemEntities;
  }

  @override
  Widget build(BuildContext context) {
    return ChartContainer(
      title: 'Most Requested Items',
      description: 'Top frequently requested items.',
      child: AspectRatio(
        aspectRatio: 1.7,
        child: BarChart(
          mainBarData(),
        ),
      ),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final index = group.x.toInt();

            if (index < 0 || index >= _effectiveData.length) return null;

            final item = _effectiveData[index];

            return BarTooltipItem(
              capitalizeWord('${item.productName}\n'),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${item.requestCount} requests',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        // touchCallback: (FlTouchEvent event, barTouchResponse) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (!mounted) return;
        //     setState(() {
        //       if (!event.isInterestedForInteractions ||
        //           barTouchResponse == null ||
        //           barTouchResponse.spot == null) {
        //         touchedIndex = -1;
        //         return;
        //       }
        //       touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
        //     });
        //   });
        // },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < _effectiveData.length) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    capitalizeWord(_effectiveData[index].productName),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }
              return Container();
            },
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: const FlGridData(show: false),
      barGroups: _effectiveData.asMap().entries.map(
        (entry) {
          final index = entry.key;
          final item = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.requestCount.toDouble(),
                color: touchedIndex == index
                    ? AppColor.chartColor.withValues(alpha: 0.8)
                    : AppColor.chartColor,
                width: 22,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _effectiveData
                      .map((e) => e.requestCount)
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  color: AppColor.chartColor.withValues(alpha: 0.1),
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }
}
