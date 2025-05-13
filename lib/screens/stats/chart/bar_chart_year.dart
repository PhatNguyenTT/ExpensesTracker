import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';

class BarChartYear extends StatelessWidget {
  final List<Expense> expenses;
  final Category category;
  final int year;
  final int selectedIndex;
  final Function(int)? onBarTap;

  const BarChartYear({
    super.key,
    required this.expenses,
    required this.category,
    required this.year,
    required this.selectedIndex,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    // final columnWidth = 10.0;

    return Row(
      children: [
        // Cột Y (giá trị tiền)
        SizedBox(
          width: 55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final maxY = _getMaxY();
              final step = maxY / 5;
              final value = maxY - i * step;
              return Text(
                NumberFormat.decimalPattern('vi_VN').format(value.toInt()),
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              );
            }),
          ),
        ),
        // Biểu đồ cột
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 12),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(context),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(4),
                    tooltipBgColor: Colors.black87,
                    direction: TooltipDirection.top,
                    fitInsideVertically: true,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      final month = group.x + 1;
                      final amount = rod.toY;
                      return BarTooltipItem(
                        '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent) {
                      final index = response?.spot?.touchedBarGroupIndex ?? -1;
                      if (index != -1) {
                        onBarTap?.call(index);
                      }
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final month = value.toInt() + 1;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            'T$month',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups(BuildContext context) {
    final monthlyTotals = List<double>.filled(12, 0);

    for (final e in expenses) {
      if (e.category.name == category.name &&
          e.date.year == year &&
          e.date.month >= 1 &&
          e.date.month <= 12) {
        monthlyTotals[e.date.month - 1] += e.amount.toDouble();
      }
    }

    return List.generate(12, (i) {
      final isSelected = i == selectedIndex;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: monthlyTotals[i],
            width: 22,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: isSelected
                  ? [Colors.orangeAccent, Colors.deepOrange]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              transform: const GradientRotation(pi / 40),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey.shade300,
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    final sameCategory =
        expenses.where((e) => e.category.name == category.name);
    final values = sameCategory.map((e) => e.amount).toList();
    if (values.isEmpty) return 100000;

    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    // ✅ Làm tròn lên mốc gần nhất 500.000đ để khớp trục Y
    final rounded = ((maxValue + 499999) ~/ 500000) * 500000;
    return rounded.toDouble();
  }
}
