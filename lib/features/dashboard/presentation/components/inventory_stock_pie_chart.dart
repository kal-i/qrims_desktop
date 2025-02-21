import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../config/themes/app_color.dart';
import '../../domain/entities/inventory_stock.dart';
import 'chart_container.dart';
import 'indicator.dart';

class InventoryStockPieChart extends StatelessWidget {
  const InventoryStockPieChart({
    super.key,
    required this.inventoryStocks,
  });

  final List<InventoryStockEntity> inventoryStocks;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = inventoryStocks.isEmpty ||
        inventoryStocks.every((stock) => stock.totalQuantity == 0);

    return ChartContainer(
      title: 'Inventory Stock Level',
      description: 'Shows the inventory stock changes.',
      child: AspectRatio(
        aspectRatio: 1.7,
        child: Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: PieChart(
                  PieChartData(
                    sections: isEmpty
                        ? _getEmptySections()
                        : _getSections(context, inventoryStocks),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0.0, // Reduced space for a tighter look
                    centerSpaceRadius:
                        80.0, // Add center space for a modern look
                    startDegreeOffset: -90, // Start from the top
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Add touch interaction if needed
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ), // Add spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Indicator(
                  color: AppColor.chartColor,
                  text: 'Supply',
                  isSquare: false,
                ),
                Indicator(
                  color: AppColor.chartColor.withValues(alpha: .5),
                  text: 'Equipment',
                  isSquare: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections(
      BuildContext context, List<InventoryStockEntity> stockLevels) {
    return stockLevels.map((stock) {
      final color = _getColorForItemType(stock.itemType);
      return PieChartSectionData(
        color: color,
        value: stock.totalQuantity.toDouble(),
        radius: 24.0,
        title: '',
      );
    }).toList();
  }

  List<PieChartSectionData> _getEmptySections() {
    return [
      PieChartSectionData(
        color: AppColor.chartColor.withValues(alpha: .5),
        value: 1,
        radius: 24,
        showTitle: false,
      ),
    ];
  }

  Color _getColorForItemType(String itemType) {
    switch (itemType) {
      case 'Supply':
        return AppColor.chartColor;
      case 'Equipment':
        return AppColor.chartColor.withValues(alpha: .5);
      default:
        return AppColor.defaultChartColor;
    }
  }
}
