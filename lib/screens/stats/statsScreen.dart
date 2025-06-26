import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/screens/stats/chart/pie_chart_with_badge.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/screens/stats/views/statsExpense.dart';
import 'package:expenses_tracker/screens/stats/views/statsExpense_year.dart';

class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const StatsScreen(this.expenses, {super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedView = 0; // 0 for Month, 1 for Year
  int _selectedType = 0; // 0 for Expense, 1 for Income
  DateTime _selectedDate = DateTime.now();

  List<Expense> _filteredExpenses = [];
  List<Expense> _summaryExpenses = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _processExpenses();
  }

  void _processExpenses() {
    final isExpense = _selectedType == 0;
    _filteredExpenses = widget.expenses.where((e) {
      final isSamePeriod = _selectedView == 0
          ? (e.date.month == _selectedDate.month &&
              e.date.year == _selectedDate.year)
          : (e.date.year == _selectedDate.year);
      final isMatchingType = isExpense
          ? e.category.type == tt.TransactionType.expense
          : e.category.type == tt.TransactionType.income;
      return isSamePeriod && isMatchingType;
    }).toList();

    final groupedExpenses = <String, Expense>{};
    for (final e in _filteredExpenses) {
      final key = e.category.categoryId;
      if (!groupedExpenses.containsKey(key)) {
        groupedExpenses[key] = e.copyWith(amount: e.amount);
      } else {
        groupedExpenses[key] = groupedExpenses[key]!.copyWith(
          amount: groupedExpenses[key]!.amount + e.amount,
        );
      }
    }
    _summaryExpenses = groupedExpenses.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    _totalAmount = _summaryExpenses.fold(0, (sum, e) => sum + e.amount);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedView,
            onValueChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedView = value;
                  _processExpenses();
                });
              }
            },
            children: const {
              0: Padding(padding: EdgeInsets.all(8), child: Text('Theo tháng')),
              1: Padding(padding: EdgeInsets.all(8), child: Text('Theo năm')),
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _selectedDate = _selectedView == 0
                      ? DateTime(_selectedDate.year, _selectedDate.month - 1)
                      : DateTime(_selectedDate.year - 1);
                  _processExpenses();
                },
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _selectedView == 0
                        ? DateFormat('MMMM yyyy', 'vi_VN').format(_selectedDate)
                        : DateFormat('yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _selectedDate = _selectedView == 0
                      ? DateTime(_selectedDate.year, _selectedDate.month + 1)
                      : DateTime(_selectedDate.year + 1);
                  _processExpenses();
                },
                icon: const Icon(Icons.chevron_right_rounded, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedType,
            thumbColor: _selectedType == 0
                ? Colors.red.shade400
                : Colors.green.shade400,
            onValueChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                  _processExpenses();
                });
              }
            },
            children: {
              0: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Chi tiêu',
                    style: TextStyle(
                        color:
                            _selectedType == 0 ? Colors.white : Colors.black)),
              ),
              1: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Thu nhập',
                    style: TextStyle(
                        color:
                            _selectedType == 1 ? Colors.white : Colors.black)),
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildChartCard(),
        const SizedBox(height: 24),
        _buildSummaryList(),
        const SizedBox(height: 60), // For floating action button space
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_usage_rounded, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const Text(
            'Không có giao dịch nào được ghi nhận trong giai đoạn này.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tổng cộng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                  .format(_totalAmount),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _selectedType == 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChartWithBadge(expenses: _filteredExpenses),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi tiết danh mục',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _summaryExpenses.length,
          itemBuilder: (context, i) {
            final e = _summaryExpenses[i];
            return _buildSummaryListItem(e);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }

  Widget _buildSummaryListItem(Expense e) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _selectedView == 0
                  ? StatsExpenseScreen(
                      expenses: widget.expenses,
                      category: e.category,
                      initialMonth: _selectedDate,
                    )
                  : StatsExpenseYearScreen(
                      expenses: widget.expenses,
                      category: e.category,
                      year: _selectedDate.year,
                    ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: e.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconMapper.getIcon(e.category.icon) ?? Icons.category,
                  color: e.category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  e.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                        .format(e.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(e.amount / _totalAmount * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
