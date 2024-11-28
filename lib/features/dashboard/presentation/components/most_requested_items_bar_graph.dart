import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../data/models/most_requested_items.dart';

class MostRequestedItemsBarChart extends StatelessWidget {
  final MostRequestedItemsModel mostRequestedItems;

  const MostRequestedItemsBarChart(
      {super.key, required this.mostRequestedItems});

  @override
  Widget build(BuildContext context) {
    print('passed data: $mostRequestedItems');
    return BaseContainer(
      color: Theme.of(context).primaryColor,
      padding: 20.0,
      height: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Most Requested Items',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontSize: 15.0),
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
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Disable right-side numbers
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // Disable numbers above bars
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
                  horizontalInterval: _getMaxY() / 5, // Divide the y-axis into 5 grid intervals
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
            // BarChart(
            //   BarChartData(
            //     alignment: BarChartAlignment.spaceAround,
            //     maxY: _getMaxY(),
            //     barGroups: _generateBarGroups(),
            //     titlesData: FlTitlesData(
            //       leftTitles: AxisTitles(
            //         sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            //       ),
            //       bottomTitles: AxisTitles(
            //         sideTitles: SideTitles(
            //           showTitles: true,
            //           getTitlesWidget: _buildBottomTitles,
            //           reservedSize: 40,
            //         ),
            //       ),
            //     ),
            //     borderData: FlBorderData(
            //       show: false,
            //     ),
            //     gridData: FlGridData(
            //       show: false,
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    print('Most Requested Items: ${mostRequestedItems.mostRequestedItems}');
    return mostRequestedItems.mostRequestedItems.asMap().entries.map((entry) {
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
            gradient: LinearGradient(
              colors: [
                AppColor.accent.withOpacity(0.7),
                AppColor.accent,
              ],
            ),
            width: 30.0,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    final maxY = mostRequestedItems.mostRequestedItems
        .map((item) => item.requestedItemData
            .fold<int>(0, (sum, current) => sum + current.quantity))
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    print('Max Y: $maxY');
    return maxY;
  }

  /// Build titles for the bottom axis.
  Widget _buildBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= 0 &&
        value.toInt() < mostRequestedItems.mostRequestedItems.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          capitalizeWord(
              mostRequestedItems.mostRequestedItems[value.toInt()].productName),
          style: const TextStyle(fontSize: 10),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Get the maximum Y value for the graph.
  // double _getMaxY() {
  //   return mostRequestedItems.mostRequestedItems
  //       .map((item) => item.requestedItemData.fold<int>(0, (sum, current) => sum + current.quantity))
  //       .reduce((a, b) => a > b ? a : b)
  //       .toDouble();
  // }
}
