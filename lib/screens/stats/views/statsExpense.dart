import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/stats/chart/bar_chart.dart'; // BarChartSample3
import 'package:expenses_tracker/utils/icon_mapper.dart';

class StatsExpenseScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Category category;
  final DateTime? initialMonth;

  const StatsExpenseScreen({
    super.key,
    required this.expenses,
    required this.category,
    this.initialMonth,
  });

  @override
  State<StatsExpenseScreen> createState() => _StatsExpenseScreenState();
}

class _StatsExpenseScreenState extends State<StatsExpenseScreen> {
  late List<DateTime> months;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    months = _generateFullMonthsUpToLatestExpense();
    if (widget.initialMonth != null) {
      final i = months.indexWhere((m) =>
          m.year == widget.initialMonth!.year &&
          m.month == widget.initialMonth!.month);
      selectedIndex = i >= 0 ? i : months.length - 1;
    } else {
      selectedIndex = months.length - 1;
    }
  }

  List<DateTime> _getLast12Months() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = DateTime(now.year, now.month - (11 - i));
      return DateTime(date.year, date.month);
    });
  }

  List<Expense> _filterExpensesByMonth(int index) {
    final m = months[index];
    return widget.expenses
        .where((e) =>
            e.category.name == widget.category.name &&
            e.date.year == m.year &&
            e.date.month == m.month)
        .toList();
  }

  List<DateTime> _generateFullMonthsUpToLatestExpense() {
    final filtered = widget.expenses
        .where((e) => e.category.name == widget.category.name)
        .toList();

    if (filtered.isEmpty) {
      final now = DateTime.now();
      return List.generate(12, (i) {
        final date = DateTime(now.year, now.month - (11 - i));
        return DateTime(date.year, date.month);
      });
    }

    // Tìm tháng xa nhất trong dữ liệu
    filtered.sort((a, b) => a.date.compareTo(b.date));
    final earliest = filtered.first.date;
    final latest = filtered.last.date;

    // Bắt đầu từ tháng đầu tiên của earliest đến cuối tháng của latest
    final months = <DateTime>[];
    DateTime current = DateTime(earliest.year, earliest.month);

    while (current.isBefore(DateTime(latest.year, latest.month + 1))) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }

    return months;
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = months[selectedIndex];
    final filtered = _filterExpensesByMonth(selectedIndex);
    final total = filtered.fold<int>(0, (a, b) => a + b.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.name} (T${currentMonth.month}/${currentMonth.year}) '
          '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(total)}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BarChartSample3(
                expenses: widget.expenses,
                category: widget.category,
                months: months,
                selectedIndex: selectedIndex,
                onBarTap: (i) => setState(() => selectedIndex = i),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(total),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có giao dịch'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final e = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: e.category.color,
                          child: Icon(
                            IconMapper.getIcon(e.category.icon),
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        title: Text(e.category.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(e.date)),
                            if (e.note != null && e.note!.isNotEmpty)
                              Text(
                                e.note!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: Text(
                          '${e.category.type.name == 'income' ? '+' : '-'}'
                          '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(e.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: e.category.type.name == 'income'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
