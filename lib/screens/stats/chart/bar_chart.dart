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
  final double _columnWidth = 24.0;
  final double _columnSpacing = 20.0;
  final ScrollController _scrollController = ScrollController();
  List<double> _monthlyTotals = [];

  @override
  void initState() {
    super.initState();
    _calculateMonthlyTotals();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelectedIndex());
  }

  @override
  void didUpdateWidget(BarChartSample3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expenses != oldWidget.expenses ||
        widget.months != oldWidget.months ||
        widget.category != oldWidget.category) {
      _calculateMonthlyTotals();
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToSelectedIndex();
    }
  }

  void _calculateMonthlyTotals() {
    _monthlyTotals = widget.months.map((month) {
      return widget.expenses
          .where((e) =>
              e.category.categoryId == widget.category.categoryId &&
              e.date.year == month.year &&
              e.date.month == month.month)
          .fold<double>(0, (sum, e) => sum + e.amount.toDouble());
    }).toList();
  }

  void _scrollToSelectedIndex() {
    final targetPosition =
        (widget.selectedIndex * (_columnWidth + _columnSpacing)) -
            (MediaQuery.of(context).size.width / 2) +
            (_columnWidth / 2);

    _scrollController.animateTo(
      targetPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_monthlyTotals.isEmpty) {
      return const Center(child: Text('Không có dữ liệu để hiển thị.'));
    }

    final maxY = _getMaxY();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildYAxis(maxY),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widget.months.length * (_columnWidth + _columnSpacing),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: _generateBarGroups(context),
                  titlesData: _buildTitlesData(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: _buildBarTouchData(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYAxis(double maxY) {
    return SizedBox(
      width: 55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(6, (i) {
          final value = maxY - (maxY / 5 * i);
          return Text(
            NumberFormat.compact(locale: 'vi_VN').format(value),
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          );
        }),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(BuildContext context) {
    return List.generate(widget.months.length, (i) {
      final isSelected = i == widget.selectedIndex;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _monthlyTotals[i],
            width: _columnWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: LinearGradient(
              colors: isSelected
                  ? [Colors.orange.shade600, Colors.orange.shade300]
                  : [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey.shade200,
            ),
          ),
        ],
      );
    });
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            final label = DateFormat('MM/yy').format(widget.months[index]);
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tooltipBgColor: Colors.black87.withOpacity(0.8),
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(rod.toY),
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
      ),
      touchCallback: (event, response) {
        if (response?.spot != null && event is FlTapUpEvent) {
          widget.onBarTap?.call(response!.spot!.touchedBarGroupIndex);
        }
      },
    );
  }

  double _getMaxY() {
    if (_monthlyTotals.isEmpty) return 100000;
    final maxValue = _monthlyTotals.reduce(max);
    if (maxValue == 0) return 100000;
    // Làm tròn lên mốc cao hơn gần nhất để biểu đồ đẹp hơn
    final orderOfMagnitude = pow(10, (log(maxValue) / ln10).floor());
    return ((maxValue / orderOfMagnitude).ceil() * orderOfMagnitude).toDouble();
  }
}
