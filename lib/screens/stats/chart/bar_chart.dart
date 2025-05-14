import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';

class BarChartSample3 extends StatefulWidget {
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
  State<BarChartSample3> createState() => _BarChartSample3State();
}

class _BarChartSample3State extends State<BarChartSample3> {
  final double columnWidth = 65.0;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = (widget.selectedIndex + 0.5) * columnWidth -
          MediaQuery.of(context).size.width / 2;
      final safeTarget =
          target.clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.jumpTo(safeTarget);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: SizedBox(
                width: widget.months.length * columnWidth,
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
                          final amount = rod.toY;
                          return BarTooltipItem(
                            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                                .format(amount),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent) {
                          final touchX = event.localPosition.dx;
                          final index =
                              (touchX ~/ 65).clamp(0, widget.months.length - 1);
                          widget.onBarTap?.call(index);
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
                            if (index < 0 || index >= widget.months.length) {
                              return const SizedBox.shrink();
                            }
                            final label = DateFormat('MM/yy')
                                .format(widget.months[index]);
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
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(BuildContext context) {
    final totals = List<double>.filled(widget.months.length, 0);

    for (int i = 0; i < widget.months.length; i++) {
      final m = widget.months[i];
      final monthTotal = widget.expenses
          .where((e) =>
              e.date.year == m.year &&
              e.date.month == m.month &&
              e.category.name == widget.category.name)
          .fold<double>(0, (sum, e) => sum + e.amount.toDouble());
      totals[i] = monthTotal;
    }

    return List.generate(widget.months.length, (i) {
      final isSelected = i == widget.selectedIndex;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totals[i],
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
    final totals = <double>[];
    for (final m in widget.months) {
      final sum = widget.expenses
          .where((e) =>
              e.date.year == m.year &&
              e.date.month == m.month &&
              e.category.name == widget.category.name)
          .fold<double>(0, (s, e) => s + e.amount.toDouble());
      totals.add(sum);
    }
    if (totals.every((v) => v == 0)) return 100000;
    final maxValue = totals.reduce(max);
    final rounded = ((maxValue + 499999) ~/ 500000) * 500000;
    return rounded.toDouble();
  }
}
