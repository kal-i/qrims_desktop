import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';

class DashboardKPICard extends StatelessWidget {
  const DashboardKPICard({
    super.key,
    required this.title,
    required this.count,
    required this.change,
  });

  final String title;
  final int count;
  final double change;

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  width: 20.0,
                ),

                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 1),
                            FlSpot(1, 1.5),
                            FlSpot(2, 1.4),
                            FlSpot(3, 3),
                          ],
                          isCurved: true,
                          color: AppColor.accent,
                          barWidth: 2.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 32.0,
              fontWeight: FontWeight.w900,
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Since last week',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Row(
                  children: [
                    Icon(
                      change > 0
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      color: change > 0
                          ? const Color(0xFF466AFA)
                          : const Color(0xFFFF7651),
                    ),
                    Text(
                      "${change.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: change > 0
                            ? const Color(0xFF466AFA)
                            : const Color(0xFFFF7651),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
