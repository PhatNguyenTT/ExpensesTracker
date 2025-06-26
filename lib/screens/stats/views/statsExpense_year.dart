import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/stats/chart/bar_chart_year.dart';
import 'package:expenses_tracker/screens/stats/views/statsExpense.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;

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
  late List<double> _monthlyTotals;

  @override
  void initState() {
    super.initState();
    _calculateMonthlyTotals();
  }

  void _calculateMonthlyTotals() {
    _monthlyTotals = List.generate(12, (i) {
      return widget.expenses
          .where((e) =>
              e.category.categoryId == widget.category.categoryId &&
              e.date.year == widget.year &&
              e.date.month == i + 1)
          .fold<double>(0, (sum, e) => sum + e.amount.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalYear =
        _monthlyTotals.fold<double>(0, (sum, amount) => sum + amount);
    final average = totalYear > 0
        ? totalYear / _monthlyTotals.where((t) => t > 0).length
        : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.category.name} (${widget.year})',
          style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildChartCard(),
          const SizedBox(height: 24),
          _buildSummaryCard(totalYear, average),
          const SizedBox(height: 24),
          _buildMonthlyList(),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: BarChartYear(
        expenses: widget.expenses,
        category: widget.category,
        year: widget.year,
        selectedIndex: DateTime.now().year == widget.year
            ? DateTime.now().month - 1
            : -1, // No month selected if not current year
        // The BarChartYear now calculates its own selected index
      ),
    );
  }

  Widget _buildSummaryCard(double totalYear, double average) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Tổng cộng', totalYear),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            _buildSummaryItem('Trung bình/tháng', average),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double value) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value),
          style: TextStyle(
            color: widget.category.type == tt.TransactionType.expense
                ? Colors.red
                : Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết theo tháng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          itemBuilder: (context, i) {
            final monthTotal = _monthlyTotals[i];
            return _buildMonthlyListItem(i, monthTotal);
          },
          separatorBuilder: (ctx, i) => const SizedBox(height: 8),
        ),
      ],
    );
  }

  Widget _buildMonthlyListItem(int index, double monthTotal) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Tháng ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(monthTotal),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: monthTotal > 0
                    ? (widget.category.type == tt.TransactionType.expense
                        ? Colors.red
                        : Colors.green)
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            if (monthTotal > 0)
              const Icon(Icons.chevron_right, color: Colors.grey)
            else
              const SizedBox(width: 24), // to align with the icon
          ],
        ),
        onTap: monthTotal == 0
            ? null
            : () {
                final selectedMonth = DateTime(widget.year, index + 1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StatsExpenseScreen(
                      expenses: widget.expenses,
                      category: widget.category,
                      initialMonth: selectedMonth,
                    ),
                  ),
                );
              },
      ),
    );
  }
}
