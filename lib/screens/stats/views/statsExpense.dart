import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/stats/chart/bar_chart.dart'; // BarChartSample3
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;

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
  late List<DateTime> _months;
  late int _selectedIndex;
  late List<Expense> _filteredExpenses;
  late double _totalAmount;

  @override
  void initState() {
    super.initState();
    _months = _generateFullMonthsUpToLatestExpense();
    if (widget.initialMonth != null) {
      final i = _months.indexWhere((m) =>
          m.year == widget.initialMonth!.year &&
          m.month == widget.initialMonth!.month);
      _selectedIndex = i >= 0 ? i : _months.length - 1;
    } else {
      _selectedIndex = _months.length - 1;
    }
    _updateFilteredData();
  }

  void _updateFilteredData() {
    final selectedMonth = _months[_selectedIndex];
    _filteredExpenses = widget.expenses
        .where((e) =>
            e.category.categoryId == widget.category.categoryId &&
            e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month)
        .toList();
    _totalAmount = _filteredExpenses.fold(0, (sum, e) => sum + e.amount);
  }

  List<DateTime> _generateFullMonthsUpToLatestExpense() {
    final filtered = widget.expenses
        .where((e) => e.category.categoryId == widget.category.categoryId)
        .toList();

    if (filtered.isEmpty) {
      final now = DateTime.now();
      return List.generate(12, (i) => DateTime(now.year, now.month - (11 - i)));
    }

    filtered.sort((a, b) => a.date.compareTo(b.date));
    final earliest = filtered.first.date;
    final latest = filtered.last.date;

    final diffInMonths = (latest.year - earliest.year) * 12 +
        (latest.month - earliest.month) +
        1;

    final startMonth =
        diffInMonths < 12 ? DateTime(latest.year, latest.month - 11) : earliest;
    final count = diffInMonths < 12 ? 12 : diffInMonths;

    return List.generate(
        count, (i) => DateTime(startMonth.year, startMonth.month + i));
  }

  @override
  Widget build(BuildContext context) {
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
          widget.category.name,
          style: const TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildChartCard(),
          const SizedBox(height: 16),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      height: 300,
      child: BarChartSample3(
        expenses: widget.expenses,
        category: widget.category,
        months: _months,
        selectedIndex: _selectedIndex,
        onBarTap: (i) {
          setState(() {
            _selectedIndex = i;
            _updateFilteredData();
          });
        },
      ),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_totalAmount)}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? const Center(
                      child: Text('Không có giao dịch trong tháng này.'))
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final e = _filteredExpenses[index];
                        return _buildTransactionTile(e);
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Expense e) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: e.category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              IconMapper.getIcon(e.category.icon),
              color: e.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(e.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (e.note != null && e.note!.isNotEmpty)
                  Text(
                    e.note!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(
            '${e.category.type == tt.TransactionType.income ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(e.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: e.category.type == tt.TransactionType.income
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
