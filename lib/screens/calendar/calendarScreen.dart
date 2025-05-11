import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/calendar/table_calendar.dart'; // Custom Table Calendar
import 'package:expenses_tracker/utils/currency_formatter.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;

class CalendarScreen extends StatefulWidget {
  final List<Expense> expenses;

  const CalendarScreen({super.key, required this.expenses});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  // Hàm lấy chi tiêu theo ngày đã chọn
  List<Expense> getExpensesForDay(DateTime day) {
    return widget.expenses.where((expense) {
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
    final monthlyIncome = widget.expenses
        .where((expense) =>
            expense.category.type == tt.TransactionType.income &&
            expense.date.year == focusedDay.year &&
            expense.date.month == focusedDay.month)
        .fold(0, (total, expense) => total + expense.amount);

    final monthlyExpense = widget.expenses
        .where((expense) =>
            expense.category.type == tt.TransactionType.expense &&
            expense.date.year == focusedDay.year &&
            expense.date.month == focusedDay.month)
        .fold(0, (total, expense) => total + expense.amount);

    final totalBalance = monthlyIncome - monthlyExpense;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top), // // Đẩy lên đúng vị trí
        child: Column(
          children: [
            // // Tiêu đề và nút tìm kiếm
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         'Lịch',
            //         style: TextStyle(
            //           fontSize: 24,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.search),
            //         onPressed: () {
            //           // Thực hiện chức năng tìm kiếm ở đây
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            // Custom Table Calendar
            CustomTableCalendar(
              focusedDay: focusedDay,
              selectedDay: selectedDay,
              expenses: widget.expenses,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  this.focusedDay = focusedDay;
                });
              },
            ),

            // Tóm tắt thu nhập, chi tiêu, tổng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard('Thu nhập', monthlyIncome, Colors.green),
                _buildSummaryCard('Chi tiêu', monthlyExpense, Colors.red),
                _buildSummaryCard('Tổng', totalBalance, Colors.blue),
              ],
            ),

            // Liệt kê chi tiêu theo ngày đã chọn
            Expanded(
              child: ListView.builder(
                itemCount: expensesForSelectedDay.length,
                shrinkWrap:
                    true, // Đảm bảo rằng ListView không chiếm quá nhiều không gian
                physics:
                    const AlwaysScrollableScrollPhysics(), // Đảm bảo ListView luôn cuộn được
                itemBuilder: (context, index) {
                  final expense = expensesForSelectedDay[index];
                  Color itemColor;

                  // Đặt màu cho giao dịch thu nhập (màu xanh) và chi tiêu (màu trắng)
                  if (expense.category.type == tt.TransactionType.income) {
                    itemColor = Colors.green; // Thu nhập sẽ có màu xanh
                  } else if (expense.category.type ==
                      tt.TransactionType.expense) {
                    itemColor = Colors.red; // Chi tiêu sẽ có màu trắng
                  } else {
                    itemColor =
                        Colors.black; // Mặc định, nếu có loại giao dịch khác
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.category,
                        color: expense.category.color,
                      ),
                      title: Text(expense.category.name),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(expense.date),
                      ),
                      trailing: Text(
                        formatSignedCurrency(expense.amount),
                        style: TextStyle(
                          color:
                              itemColor, // Sử dụng màu cho từng loại giao dịch
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Hàm hỗ trợ để tạo các card tóm tắt thu nhập, chi tiêu, tổng
  Widget _buildSummaryCard(String title, int amount, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            // const SizedBox(height: 2),
            Text(
              formatSignedCurrency(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
