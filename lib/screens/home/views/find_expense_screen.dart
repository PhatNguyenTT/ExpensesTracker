import 'package:collection/collection.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;

class FindExpenseScreen extends StatefulWidget {
  final List<Expense> allExpenses;

  const FindExpenseScreen({super.key, required this.allExpenses});

  @override
  State<FindExpenseScreen> createState() => _FindExpenseScreenState();
}

class _FindExpenseScreenState extends State<FindExpenseScreen> {
  final _searchController = TextEditingController();
  List<Expense> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Khởi tạo danh sách rỗng, không hiển thị gì ban đầu
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Nếu không có query, danh sách kết quả là rỗng
        _filteredExpenses = [];
      } else {
        _filteredExpenses = widget.allExpenses.where((e) {
          final categoryMatch = e.category.name.toLowerCase().contains(query);
          final noteMatch = e.note?.toLowerCase().contains(query) ?? false;
          return categoryMatch || noteMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán summary từ kết quả lọc
    final income = _filteredExpenses
        .where((e) => e.category.type == tt.TransactionType.income)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = _filteredExpenses
        .where((e) => e.category.type == tt.TransactionType.expense)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final balance = income - expense;

    // Nhóm kết quả theo ngày
    final groupedByDay = groupBy(_filteredExpenses,
        (Expense e) => DateTime(e.date.year, e.date.month, e.date.day));
    final sortedDays = groupedByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chỉ hiển thị summary header khi có kết quả
          if (_filteredExpenses.isNotEmpty)
            _buildSummaryHeader(income, expense, balance),
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildInitialEmptyState()
                : _filteredExpenses.isEmpty
                    ? _buildNoResultsState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sortedDays.length,
                        itemBuilder: (context, index) {
                          final day = sortedDays[index];
                          final dailyExpenses = groupedByDay[day]!;
                          return _buildDailyExpenseCard(day, dailyExpenses);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      automaticallyImplyLeading: false, // Tắt nút back mặc định
      title: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng', style: TextStyle(fontSize: 16)),
          ),
          const Expanded(
            child: Text(
              'Tìm giao dịch',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: 56), // Để cân bằng với nút Đóng
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tìm theo #nhãn, nhóm, v.v...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(double income, double expense, double balance) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_filteredExpenses.length} kết quả',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Khoản thu', income, Colors.green),
          const SizedBox(height: 4),
          _buildSummaryRow('Khoản chi', expense, Colors.red),
          const Divider(height: 16),
          _buildSummaryRow(
              'Số dư', balance, balance >= 0 ? Colors.green : Colors.red,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(
          NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(value),
          style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInitialEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tìm kiếm giao dịch',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Text(
            'Nhập từ khóa để bắt đầu tìm kiếm.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy kết quả',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Text(
            'Hãy thử tìm kiếm với từ khóa khác.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyExpenseCard(DateTime day, List<Expense> expenses) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(day).toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...expenses.map((e) => _buildExpenseTile(e)),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense) {
    final isExpense = expense.category.type == tt.TransactionType.expense;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: expense.category.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconMapper.getIcon(expense.category.icon),
              color: expense.category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.category.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(expense.amount)}',
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
