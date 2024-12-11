import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/enums/asset_classification.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../data/models/inventory_summary.dart';

class InventorySummaryPieChart extends StatelessWidget {
  final InventorySummaryModel inventoryData;

  const InventorySummaryPieChart({
    super.key,
    required this.inventoryData,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total value
    final totalValue = inventoryData.categoricalInventoryData
        .fold<double>(0, (sum, data) => sum + data.totalStock);

    // Generate pie chart sections with percentages
    final sections = inventoryData.categoricalInventoryData.map((data) {
      final percentage = (data.totalStock / totalValue) * 100;
      return PieChartSectionData(
        color: _getColorForCategory(data.categoryName),
        value: data.totalStock.toDouble(),
        title: '',
        radius: 20.0,
      );
    }).toList();

    return BaseContainer(
      padding: 20.0,
      height: 300.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Categorical Inventory Data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15.0,
                ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  const SizedBox(
                    width: 30.0,
                  ),

                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          inventoryData.categoricalInventoryData.map((data) {
                        final percentage = (data.totalStock / totalValue) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    // Color indicator
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _getColorForCategory(
                                          data.categoryName,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    // Category name
                                    Expanded(
                                      child: Text(
                                        readableEnumConverter(
                                            data.categoryName),
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              // Percentage
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A function to map AssetClassification to specific colors
  Color _getColorForCategory(String category) {
    switch (AssetClassification.values.firstWhere(
        (e) => e.toString().split('.').last == category,
        orElse: () => AssetClassification.unknown)) {
      case AssetClassification.buildingsAndStructure:
        return const Color(0xFFECEBF8);
      case AssetClassification.furnitureFixturesAndBooks:
        return const Color(0xFFBFBAED);
      case AssetClassification.machineryAndEquipment:
        return AppColor.accent;
        return const Color(0xFFB6C9FF);
      case AssetClassification.transportation:
        return const Color(0xFFA4BCFF);
      case AssetClassification.unknown:
      default:
        return const Color(0xFF8377D0);
    }
  }
}
