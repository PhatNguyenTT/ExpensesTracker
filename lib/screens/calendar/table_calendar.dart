import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;

bool isSameMonth(DateTime day1, DateTime day2) =>
    day1.year == day2.year && day1.month == day2.month;

class CustomTableCalendar extends StatefulWidget {
  const CustomTableCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    this.expenses,
    this.onPageChanged,
    this.onDaySelected,
  }) : super(key: key);

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Expense>? expenses;
  final Function(DateTime)? onPageChanged;
  final Function(DateTime, DateTime)? onDaySelected;

  @override
  State<CustomTableCalendar> createState() => _CustomTableCalendarState();
}

class _CustomTableCalendarState extends State<CustomTableCalendar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Tính tổng amount cho một ngày
  double _getTotalAmountForDay(DateTime day) {
    if (widget.expenses == null) return 0;

    return widget.expenses!
        .where((expense) => isSameDay(expense.date, day))
        .fold(0.0, (total, expense) {
      if (expense.category.type == tt.TransactionType.income) {
        return total + expense.amount;
      } else {
        return total - expense.amount;
      }
    });
  }

  // Đếm số giao dịch cho một ngày
  int _getTransactionCountForDay(DateTime day) {
    if (widget.expenses == null) return 0;
    return widget.expenses!
        .where((expense) => isSameDay(expense.date, day))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: TableCalendar(
        locale: 'vi_VN',
        firstDay: DateTime.utc(2000),
        lastDay: DateTime.utc(2100),
        focusedDay: widget.focusedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
        onPageChanged: (focusedDay) {
          if (widget.onPageChanged != null) widget.onPageChanged!(focusedDay);
        },
        onDaySelected: (mySelectedDay, myFocusedDay) {
          if (!isSameDay(widget.selectedDay, mySelectedDay) &&
              isSameMonth(widget.focusedDay, mySelectedDay) &&
              widget.onDaySelected != null) {
            widget.onDaySelected!(mySelectedDay, myFocusedDay);
            _animationController.forward().then((_) {
              _animationController.reset();
            });
          }
        },
        eventLoader: (day) {
          return widget.expenses != null
              ? widget.expenses!
                  .where((expense) => isSameDay(expense.date, day))
                  .toList()
              : [];
        },
        calendarStyle: CalendarStyle(
          // Xóa border mặc định
          tableBorder: const TableBorder(),

          // Cell styling
          cellPadding: const EdgeInsets.all(6),
          cellMargin: const EdgeInsets.all(2),

          // Today styling
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade300, width: 2),
          ),
          todayTextStyle: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),

          // Selected day styling
          selectedDecoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),

          // Default day styling
          defaultDecoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          defaultTextStyle: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),

          // Weekend styling
          weekendDecoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          weekendTextStyle: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),

          // Outside days styling
          outsideDaysVisible: true,
          outsideDecoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          outsideTextStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),

          // Disable default markers
          markersMaxCount: 0,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          rightChevronPadding: const EdgeInsets.all(8),
          leftChevronPadding: const EdgeInsets.all(8),

          // Header decoration
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),

          headerPadding: const EdgeInsets.symmetric(vertical: 16),
          headerMargin: const EdgeInsets.all(0),

          // Title styling
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blue.shade800,
          ),
          titleTextFormatter: (date, locale) {
            return "Tháng ${DateFormat('M').format(date)} - ${DateFormat('yyyy').format(date)}";
          },

          // Chevron styling
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          // Hide outside days from different months
          prioritizedBuilder: (context, day, focusedDay) {
            if (day.month != focusedDay.month || day.year != focusedDay.year) {
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }
            return null;
          },

          // Custom marker builder với visual indicators đẹp hơn
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty && isSameMonth(widget.focusedDay, day)) {
              final transactionCount = _getTransactionCountForDay(day);
              final totalAmount = _getTotalAmountForDay(day);
              final isSelected = isSameDay(day, widget.selectedDay);
              final isToday = isSameDay(day, DateTime.now());

              return Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: totalAmount >= 0
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.red.shade400, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (totalAmount >= 0 ? Colors.green : Colors.red)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    transactionCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },

          // Custom day of week builder
          dowBuilder: (context, day) {
            final isWeekend = day.weekday == DateTime.sunday ||
                day.weekday == DateTime.saturday;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isWeekend ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  DateFormat.E('vi_VN').format(day).toUpperCase(),
                  style: TextStyle(
                    color:
                        isWeekend ? Colors.red.shade600 : Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },

          // Custom default day builder với animation
          defaultBuilder: (context, day, focusedDay) {
            final events = widget.expenses
                    ?.where((expense) => isSameDay(expense.date, day))
                    .toList() ??
                [];
            final hasEvents = events.isNotEmpty;
            final totalAmount = _getTotalAmountForDay(day);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: hasEvents
                    ? (totalAmount >= 0
                        ? Colors.green.shade50
                        : Colors.red.shade50)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: hasEvents
                    ? Border.all(
                        color: totalAmount >= 0
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasEvents
                        ? (totalAmount >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700)
                        : Colors.grey.shade800,
                    fontWeight: hasEvents ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
