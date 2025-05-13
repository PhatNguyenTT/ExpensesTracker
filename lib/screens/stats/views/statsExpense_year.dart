import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/stats/chart/bar_chart_year.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';

class StatsExpenseYearScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Category category;
  final int year;

  const StatsExpenseYearScreen({
    super.key,
    required this.expenses,
    required this.category,
    required this.year,
  });

  @override
  State<StatsExpenseYearScreen> createState() => _StatsExpenseYearScreenState();
}

class _StatsExpenseYearScreenState extends State<StatsExpenseYearScreen> {
  int selectedMonthIndex = DateTime.now().month - 1;

  List<Expense> _expensesInMonth(int month) {
    return widget.expenses.where((e) {
      return e.category.name == widget.category.name &&
          e.date.year == widget.year &&
          e.date.month == month + 1;
    }).toList();
  }

  List<double> _totalsPerMonth() {
    return List.generate(12, (i) {
      return _expensesInMonth(i)
          .fold<double>(0, (sum, e) => sum + e.amount.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalYear =
        _totalsPerMonth().fold<double>(0, (sum, amount) => sum + amount);
    final average = totalYear / 12;
    final selectedMonth = selectedMonthIndex + 1;
    final selectedExpenses = _expensesInMonth(selectedMonthIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.name} (Năm ${widget.year})',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🔷 Biểu đồ
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChartYear(
                expenses: widget.expenses,
                category: widget.category,
                year: widget.year,
                selectedIndex: selectedMonthIndex,
                onBarTap: (i) => setState(() => selectedMonthIndex = i),
              ),
            ),
          ),

          // 🔷 Tổng & Trung bình
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(totalYear),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trung bình',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(average),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 🔷 Danh sách tháng
          Expanded(
            child: ListView.builder(
              itemCount: 12,
              itemBuilder: (context, i) {
                final monthLabel = 'Tháng ${i + 1}';
                final monthTotal = _totalsPerMonth()[i];
                return ListTile(
                  title: Text(monthLabel),
                  trailing: Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(monthTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: monthTotal == 0
                      ? null
                      : () => setState(() => selectedMonthIndex = i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
