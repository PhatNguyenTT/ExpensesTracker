import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/calendar/table_calendar.dart'; // Custom Table Calendar
import 'package:expenses_tracker/utils/currency_formatter.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/utils/icon_mapper.dart';

class CalendarScreen extends StatefulWidget {
  final List<Expense> allExpenses;

  const CalendarScreen({super.key, required this.allExpenses});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hàm lấy chi tiêu theo ngày đã chọn
  List<Expense> getExpensesForDay(DateTime day) {
    return widget.allExpenses.where((expense) {
      return expense.date.year == day.year &&
          expense.date.month == day.month &&
          expense.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesForSelectedDay = getExpensesForDay(selectedDay);

    // Tính tổng thu nhập, chi tiêu, và tổng số dư cho tháng
    // Hàm tính tổng thu nhập, chi tiêu, và tổng số dư cho tháng hiện tại
    final monthlyIncome = widget.allExpenses
        .where((expense) =>
            expense.category.type == tt.TransactionType.income &&
            expense.date.year == focusedDay.year &&
            expense.date.month == focusedDay.month)
        .fold(0, (total, expense) => total + expense.amount);

    final monthlyExpense = widget.allExpenses
        .where((expense) =>
            expense.category.type == tt.TransactionType.expense &&
            expense.date.year == focusedDay.year &&
            expense.date.month == focusedDay.month)
        .fold(0, (total, expense) => total + expense.amount);

    final totalBalance = monthlyIncome - monthlyExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header với title và date info
              _buildHeader(),

              // Custom Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTableCalendar(
                      focusedDay: focusedDay,
                      selectedDay: selectedDay,
                      expenses: widget.allExpenses,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          this.selectedDay = selectedDay;
                          this.focusedDay = focusedDay;
                        });
                        _animationController.reset();
                        _animationController.forward();
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          this.focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Summary Cards với gradient và animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSummarySection(
                    monthlyIncome, monthlyExpense, totalBalance),
              ),

              const SizedBox(height: 20),

              // Header cho danh sách giao dịch
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(selectedDay),
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${expensesForSelectedDay.length} giao dịch',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Danh sách giao dịch với animation và height cố định để scroll
              Container(
                height: 400, // Chiều cao cố định cho danh sách giao dịch
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: expensesForSelectedDay.isEmpty
                      ? _buildEmptyState()
                      : _buildExpensesList(expensesForSelectedDay),
                ),
              ),

              const SizedBox(
                  height: 20), // Khoảng cách cuối để tránh cắt nội dung
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Text(
            'Lịch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _showSearchDialog();
            },
            icon: Icon(
              Icons.search_rounded,
              color: Colors.grey.shade600,
              size: 24,
            ),
            tooltip: 'Tìm kiếm giao dịch',
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text('Tìm kiếm giao dịch'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập tên giao dịch...',
                  prefixIcon: Icon(Icons.text_fields_rounded,
                      color: Colors.grey.shade500),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade400),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search logic
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Tính năng tìm kiếm sẽ được phát triển trong phiên bản tiếp theo.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummarySection(
      int monthlyIncome, int monthlyExpense, int totalBalance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildModernSummaryCard(
              'Thu nhập',
              monthlyIncome,
              [Colors.green.shade400, Colors.green.shade600],
              Icons.arrow_upward_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernSummaryCard(
              'Chi tiêu',
              monthlyExpense,
              [Colors.red.shade400, Colors.red.shade600],
              Icons.arrow_downward_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildModernSummaryCard(
              'Tổng',
              totalBalance,
              totalBalance >= 0
                  ? [Colors.blue.shade400, Colors.blue.shade600]
                  : [Colors.orange.shade400, Colors.orange.shade600],
              totalBalance >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryCard(
      String title, int amount, List<Color> gradientColors, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title == 'Tổng'
                      ? formatSignedCurrency(amount)
                      : formatCurrency(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có giao dịch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có giao dịch nào trong ngày này',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final isIncome = expense.category.type == tt.TransactionType.income;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: expense.category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconMapper.getIcon(expense.category.icon),
                color: expense.category.color,
                size: 20,
              ),
            ),
            title: Text(
              expense.category.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: expense.note != null && expense.note!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      expense.note!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${formatSignedCurrency(expense.amount)}',
                  style: TextStyle(
                    color:
                        isIncome ? Colors.green.shade600 : Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(expense.date),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
