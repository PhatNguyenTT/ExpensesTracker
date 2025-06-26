import 'dart:math';

import 'package:collection/collection.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/screens/home/views/find_expense_screen.dart';

class ViewAllExpenses extends StatefulWidget {
  final List<Expense> expenses;
  const ViewAllExpenses({super.key, required this.expenses});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {
  late PageController _pageController;
  late ScrollController _monthScrollController;
  late dynamic _selectedPageKey;
  late List<dynamic> _pageKeys;
  late int _initialPage;
  late double _totalBalance;
  late Map<dynamic, List<Expense>> _pagesData;

  @override
  void initState() {
    super.initState();
    _processAndSetupData();

    _pageController = PageController(initialPage: _initialPage);
    _monthScrollController = ScrollController();
    _selectedPageKey =
        _pageKeys.isNotEmpty ? _pageKeys[_initialPage] : DateTime.now();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToSelectedMonth());
  }

  void _processAndSetupData() {
    final now = DateTime.now();
    final currentMonthKey = DateTime(now.year, now.month);
    _pagesData = {};

    // 1. Tạo danh sách 12 tháng gần nhất làm key cơ bản
    final last12Months = List.generate(12, (i) {
      return DateTime(currentMonthKey.year, currentMonthKey.month - i);
    }).reversed.toList();

    // Gán dữ liệu cho 12 tháng gần nhất
    for (var monthKey in last12Months) {
      _pagesData[monthKey] = widget.expenses
          .where((e) =>
              e.date.year == monthKey.year && e.date.month == monthKey.month)
          .toList();
    }

    // 2. Lọc và gom nhóm các giao dịch trong tương lai
    final futureExpenses = widget.expenses.where((e) {
      final expenseMonthKey = DateTime(e.date.year, e.date.month);
      return expenseMonthKey.isAfter(currentMonthKey);
    }).toList();

    // 3. Chỉ thêm mục "Tương lai" nếu có giao dịch
    if (futureExpenses.isNotEmpty) {
      _pagesData['Future'] = futureExpenses;
    }

    // 4. Xây dựng danh sách keys và đặt trang mặc định
    _pageKeys = _pagesData.keys.toList();
    _initialPage = _pageKeys.indexOf(currentMonthKey);
    if (_initialPage < 0) _initialPage = 0; // Fallback

    // Tính tổng số dư
    _totalBalance = widget.expenses.fold(0.0, (sum, e) {
      return e.category.type == tt.TransactionType.expense
          ? sum - e.amount
          : sum + e.amount;
    });
  }

  void _scrollToSelectedMonth() {
    if (_monthScrollController.hasClients) {
      // Giả sử mỗi item có chiều rộng khoảng 120
      const itemWidth = 120.0;
      final screenWidth = MediaQuery.of(context).size.width;

      // Tính toán vị trí để đưa item vào giữa màn hình
      final scrollPosition =
          (_initialPage * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      _monthScrollController.animateTo(
        scrollPosition.clamp(
            0.0, _monthScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _monthScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: _pageKeys.isEmpty
                ? const Center(
                    child: Text("Không có giao dịch nào.",
                        style: TextStyle(color: Colors.grey)))
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _pageKeys.length,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedPageKey = _pageKeys[index];
                      });
                    },
                    itemBuilder: (context, index) {
                      final pageKey = _pageKeys[index];
                      final pageExpenses = _pagesData[pageKey] ?? [];

                      return MonthlyExpensePage(
                        pageKey: pageKey,
                        expenses: pageExpenses,
                        allExpenses: widget.expenses,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[100],
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Số dư',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(_totalBalance),
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FindExpenseScreen(allExpenses: widget.expenses),
              ),
            );
          },
          icon: const Icon(Icons.search, color: Colors.black87, size: 28),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz, color: Colors.black87, size: 28),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _pageKeys.length,
        itemBuilder: (context, index) {
          final pageKey = _pageKeys[index];

          // Logic để xác định nhãn cho từng mục
          final String label;
          final now = DateTime.now();
          final currentMonthKey = DateTime(now.year, now.month);
          final previousMonthKey = DateTime(now.year, now.month - 1);

          final bool isCurrentMonth = (pageKey is DateTime &&
              pageKey.year == currentMonthKey.year &&
              pageKey.month == currentMonthKey.month);
          final bool isPreviousMonth = (pageKey is DateTime &&
              pageKey.year == previousMonthKey.year &&
              pageKey.month == previousMonthKey.month);
          final bool isFuture = pageKey is String && pageKey == 'Future';

          if (isCurrentMonth) {
            label = 'Tháng này';
          } else if (isPreviousMonth) {
            label = 'Tháng trước';
          } else if (isFuture) {
            label = 'Tương lai';
          } else {
            label = DateFormat('MM/yyyy').format(pageKey as DateTime);
          }

          final isSelected = (_selectedPageKey is DateTime &&
                  pageKey is DateTime &&
                  pageKey.year == _selectedPageKey.year &&
                  pageKey.month == _selectedPageKey.month) ||
              (_selectedPageKey == 'Future' && pageKey == 'Future');

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MonthlyExpensePage extends StatelessWidget {
  final dynamic pageKey;
  final List<Expense> expenses;
  final List<Expense> allExpenses;

  const MonthlyExpensePage({
    super.key,
    required this.pageKey,
    required this.expenses,
    required this.allExpenses,
  });

  @override
  Widget build(BuildContext context) {
    // Logic tính toán cho trang này
    double openingBalance;
    if (pageKey is DateTime) {
      openingBalance = allExpenses.where((e) => e.date.isBefore(pageKey)).fold(
          0.0,
          (sum, e) => e.category.type == tt.TransactionType.expense
              ? sum - e.amount
              : sum + e.amount);
    } else {
      // Tính số dư đầu kỳ cho mục "Tương lai"
      final now = DateTime.now();
      final startOfNextMonth = DateTime(now.year, now.month + 1);
      openingBalance = allExpenses
          .where((e) => e.date.isBefore(startOfNextMonth))
          .fold(
              0.0,
              (sum, e) => e.category.type == tt.TransactionType.expense
                  ? sum - e.amount
                  : sum + e.amount);
    }

    final netChange = expenses.fold(
        0.0,
        (sum, e) => e.category.type == tt.TransactionType.expense
            ? sum - e.amount
            : sum + e.amount);

    final closingBalance = openingBalance + netChange;

    final groupedByDay = groupBy(expenses,
        (Expense e) => DateTime(e.date.year, e.date.month, e.date.day));

    final sortedDays = groupedByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(openingBalance, closingBalance, netChange),
            const SizedBox(height: 24),
            ...sortedDays.map((day) {
              final dailyExpenses = groupedByDay[day]!;
              return DailyExpenseCard(day: day, expenses: dailyExpenses);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double opening, double closing, double net) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Số dư đầu', opening),
          const SizedBox(height: 12),
          _buildSummaryRow('Số dư cuối', closing),
          const Divider(height: 24, color: Colors.black12),
          _buildSummaryRow('Thay đổi', net, isNet: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isNet = false}) {
    final color =
        isNet ? (value >= 0 ? Colors.green : Colors.red) : Colors.black87;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Text(
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value),
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DailyExpenseCard extends StatelessWidget {
  final DateTime day;
  final List<Expense> expenses;

  const DailyExpenseCard({
    super.key,
    required this.day,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final dayTotal = expenses.fold(
        0.0,
        (sum, e) => e.category.type == tt.TransactionType.expense
            ? sum - e.amount
            : sum + e.amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header của ngày
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  DateFormat('dd').format(day),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', 'vi_VN').format(day),
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'vi_VN').format(day),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                      .format(dayTotal),
                  style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Danh sách các giao dịch trong ngày
          ...expenses.map((e) => _buildExpenseTile(e)),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense) {
    final isExpense = expense.category.type == tt.TransactionType.expense;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: expense.category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              IconMapper.getIcon(expense.category.icon),
              color: expense.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              expense.category.name,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                .format(expense.amount),
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
