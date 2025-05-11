import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';

class BarChartSample3 extends StatelessWidget {
  final List<Expense> expenses;
  final Category category;
  final List<DateTime> months;
  final int selectedIndex;
  final Function(int)? onBarTap;

  const BarChartSample3({
    super.key,
    required this.expenses,
    required this.category,
    required this.months,
    required this.selectedIndex,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    const columnWidth = 65.0;

    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: 60,
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
          // ✅ Biểu đồ với scroll ngang
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true, // ✅ Đảm bảo hiển thị 5 tháng gần nhất
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: months.length * columnWidth,
                child: GestureDetector(
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
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            final date = months[group.x.toInt()];
                            final amount = rod.toY;
                            return BarTooltipItem(
                              // '${DateFormat('MM/yyyy').format(date)}\n'
                              '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount)}',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent && response?.spot != null) {
                            final index = response!.spot!.touchedBarGroupIndex;
                            onBarTap?.call(index);
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
                              final index = value.toInt();
                              if (index < 0 || index >= months.length) {
                                return const SizedBox.shrink();
                              }
                              final label =
                                  DateFormat('MM/yy').format(months[index]);
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(context) {
    final totals = List<double>.filled(months.length, 0);

    for (final e in expenses) {
      if (e.category.name == category.name) {
        for (int i = 0; i < months.length; i++) {
          final m = months[i];
          if (e.date.year == m.year && e.date.month == m.month) {
            totals[i] += e.amount.toDouble();
          }
        }
      }
    }

    return List.generate(months.length, (i) {
      final isSelected = i == selectedIndex;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totals[i],
            width: 22,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      Colors.orangeAccent,
                      Colors.deepOrange,
                    ]
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
    final rounded = ((maxValue * 1.25) / 100000).ceil() * 100000;
    return rounded.toDouble();
  }
}
