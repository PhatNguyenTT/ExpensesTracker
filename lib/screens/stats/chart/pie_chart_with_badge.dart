import 'package:expense_repository/expense_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';

class PieChartWithBadge extends StatefulWidget {
  final List<Expense> expenses;

  const PieChartWithBadge({super.key, required this.expenses});

  @override
  State<PieChartWithBadge> createState() => _PieChartWithBadgeState();
}

class _PieChartWithBadgeState extends State<PieChartWithBadge> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response?.touchedSection == null) {
                  touchedIndex = -1;
                } else {
                  touchedIndex = response!.touchedSection!.touchedSectionIndex;
                }
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final Map<String, double> categoryTotals = {};
    final Map<String, Category> categoryMap = {};

    for (final expense in widget.expenses) {
      final id = expense.category.name;
      categoryTotals[id] =
          (categoryTotals[id] ?? 0) + expense.amount.abs().toDouble();
      categoryMap[id] = expense.category;
    }

    final totalAmount = categoryTotals.values.fold(0.0, (a, b) => a + b);

    int index = -1;
    return categoryTotals.entries.map((entry) {
      index++;
      final percent = (entry.value / totalAmount) * 100;
      final category = categoryMap[entry.key]!;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      final icon = IconMapper.getIcon(category.icon);

      return PieChartSectionData(
        color: category.color,
        value: percent,
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: _Badge(
          icon: icon,
          size: widgetSize,
          borderColor: Colors.black,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }
}

class _Badge extends StatelessWidget {
  final IconData? icon;
  final double size;
  final Color borderColor;

  const _Badge({
    required this.icon,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(
          icon ?? Icons.category,
          size: size * 0.5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
