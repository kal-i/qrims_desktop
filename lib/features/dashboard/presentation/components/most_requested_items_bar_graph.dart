import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../data/models/requested_item.dart';
import '../../data/models/requests_summary.dart';

class MostRequestedItemsBarChart extends StatelessWidget {
  final List<RequestedItemModel> mostRequestedItems;

  const MostRequestedItemsBarChart({
    super.key,
    required this.mostRequestedItems,
  });

  @override
  Widget build(BuildContext context) {
    print('passed data: $mostRequestedItems');
    return BaseContainer(
      padding: 20.0,
      height: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Most Requested Items Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15.0,
                ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barGroups: _generateBarGroups(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Disable right-side numbers
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Disable numbers above bars
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _buildBottomTitles,
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval: 1, // Spacing between vertical grid lines
                  horizontalInterval:
                      _getMaxY() / 5, // Divide the y-axis into 5 grid intervals
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.5), // Grid line color
                      strokeWidth: 1, // Thickness of grid lines
                      dashArray: [4, 4], // Dashed grid lines (optional)
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.5),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return mostRequestedItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      final totalQuantity = item.requestedItemData.fold<int>(
        0,
        (sum, current) => sum + current.quantity,
      );

      print('Item: ${item.productName}, Total Quantity: $totalQuantity');

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalQuantity.toDouble(),
            color: AppColor.accent,
            // gradient: LinearGradient(
            //   colors: [
            //     AppColor.accent.withOpacity(0.7),
            //     AppColor.accent,
            //   ],
            // ),
            width: 30.0,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    final maxY = mostRequestedItems
        .map((item) => item.requestedItemData
            .fold<int>(0, (sum, current) => sum + current.quantity))
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    print('Max Y: $maxY');
    return maxY;
  }

  /// Build titles for the bottom axis.
  Widget _buildBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= 0 && value.toInt() < mostRequestedItems.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          capitalizeWord(mostRequestedItems[value.toInt()].productName),
          style: TextStyle(
            color: AppColor.darkDescriptionText,
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
