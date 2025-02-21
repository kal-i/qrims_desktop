import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../domain/entities/fulfilled_request_trend.dart';
import 'chart_container.dart';

class FulfilledRequestOverTimeLineChart extends StatelessWidget {
  const FulfilledRequestOverTimeLineChart({
    super.key,
    required this.fulfilledRequestTrendEntities,
  });

  final List<FulfilledRequestTrendEntity> fulfilledRequestTrendEntities;

  @override
  Widget build(BuildContext context) {
    // Convert the data into FlSpot objects for the chart
    final List<FlSpot> spots = [];
    for (int i = 0; i < fulfilledRequestTrendEntities.length; i++) {
      final entity = fulfilledRequestTrendEntities[i];
      spots.add(FlSpot(i.toDouble(), entity.requestCount.toDouble()));
    }

    // Generate bottom titles (dates)
    final Map<int, String> bottomTitles = {};
    for (int i = 0; i < fulfilledRequestTrendEntities.length; i++) {
      final date = fulfilledRequestTrendEntities[i].date;
      bottomTitles[i] =
          '${date.month}/${date.day}'; // Format the date as needed
    }

    // Generate left titles (counts)
    final Map<int, String> leftTitles = {};
    final maxCount = fulfilledRequestTrendEntities.isNotEmpty
        ? fulfilledRequestTrendEntities
            .map((e) => e.requestCount)
            .reduce((a, b) => a > b ? a : b)
        : 0; // Default value if the list is empty

    if (maxCount > 0) {
      final interval =
          (maxCount ~/ 5).clamp(1, maxCount); // Ensure interval is at least 1
      for (int i = 0; i <= maxCount; i += interval) {
        leftTitles[i] = i.toString();
      }
    } else {
      leftTitles[0] = '0'; // Default value if maxCount is 0
    }

    return ChartContainer(
      title: 'Fulfilled Requests Over Time',
      description: 'Shows fulfilled requests over time.',
      child: AspectRatio(
        aspectRatio: 16 / 6,
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(
              handleBuiltInTouches: false,
            ),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return bottomTitles[value.toInt()] != null
                        ? SideTitleWidget(
                            meta: meta, // Use meta instead of axisSide
                            child: Text(
                              bottomTitles[value.toInt()]!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          )
                        : const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return leftTitles[value.toInt()] != null
                        ? Text(
                            leftTitles[value.toInt()]!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          )
                        : const SizedBox();
                  },
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                color: AppColor.chartColor, // Replace with your desired color
                barWidth: 1.5,
                belowBarData: BarAreaData(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColor.chartColor.withValues(
                          alpha: .5), // Replace with your desired color
                      Colors.transparent,
                    ],
                  ),
                  show: true,
                ),
                dotData: FlDotData(show: false),
                spots: spots,
              ),
            ],
            minX: 0,
            maxX: fulfilledRequestTrendEntities.length.toDouble() - 1,
            maxY: maxCount.toDouble(),
            minY: 0,
          ),
        ),
      ),
    );
  }
}
