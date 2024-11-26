import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';

class StockLevelPieChart extends StatelessWidget {
  final int inStocksCount;
  final int lowStocksCount;
  final int outOfStocksCount;

  const StockLevelPieChart({
    super.key,
    required this.inStocksCount,
    required this.lowStocksCount,
    required this.outOfStocksCount,
  });

  @override
  Widget build(BuildContext context) {
    // Total items for percentage calculation
    final totalCount = inStocksCount + lowStocksCount + outOfStocksCount;

    // Generate Pie Chart Sections
    final sections = [
      _buildPieSection(context, 'In Stocks', inStocksCount, totalCount),
      _buildPieSection(context, 'Low Stocks', lowStocksCount, totalCount),
      _buildPieSection(context, 'Out of Stocks', outOfStocksCount, totalCount),
    ];

    return BaseContainer(
      color: Theme.of(context).primaryColor,
      padding: 20.0,
      height: 300.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stock Levels',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontSize: 15.0),
          ),
          const SizedBox(height: 20.0,),
          Expanded(
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 80.0,
                      sectionsSpace: 0.0,
                    ),
                  ),
                ),
                const SizedBox(width: 30.0),
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        context,
                        'In Stocks',
                        inStocksCount,
                        totalCount,
                        const Color(0xFF0BA293),
                      ),
                      _buildLegendItem(
                        context,
                        'Low Stocks',
                        lowStocksCount,
                        totalCount,
                        const Color(0xFFFFC641),
                      ),
                      _buildLegendItem(
                        context,
                        'Out of Stocks',
                        outOfStocksCount,
                        totalCount,
                        const Color(0xFFFF474D),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a Pie Chart Section for a specific category.
  PieChartSectionData _buildPieSection(
      BuildContext context, String category, int count, int totalCount) {
    final percentage = (count / totalCount) * 100;
    return PieChartSectionData(
      color: _getColorForCategory(category),
      value: count.toDouble(),
      title: '${percentage.toStringAsFixed(1)}%',
      titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColor.accent,
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
          ),
      radius: 5.0,
    );
  }

  /// Builds a legend item with color, category name, and percentage.
  Widget _buildLegendItem(
    BuildContext context,
    String category,
    int count,
    int totalCount,
    Color color,
  ) {
    final percentage = (count / totalCount) * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10.0),
          // Category name
          Expanded(
            child: Text(
              category,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          // Percentage
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  /// Maps categories to colors.
  Color _getColorForCategory(String category) {
    switch (category) {
      case 'In Stocks':
        return const Color(0xFF0BA293);
      case 'Low Stocks':
        return const Color(0xFFFFC641);
      case 'Out of Stocks':
        return const Color(0xFFFF474D);
      default:
        return AppColor.accentDisable;
    }
  }
}
