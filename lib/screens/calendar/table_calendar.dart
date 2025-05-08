import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expense_repository/expense_repository.dart';

bool isSameMonth(DateTime day1, DateTime day2) =>
    day1.year == day2.year && day1.month == day2.month;

BorderSide customBorderSide() => const BorderSide(
    color: Colors.black12, width: 1.0, style: BorderStyle.solid);

class CustomTableCalendar extends StatelessWidget {
  const CustomTableCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    this.expenses, // Để nhận dữ liệu từ widget cha
    this.onPageChanged,
    this.onDaySelected,
  }) : super(key: key);

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Expense>? expenses; // Sử dụng model Expense từ repository
  final Function(DateTime)? onPageChanged;
  final Function(DateTime, DateTime)? onDaySelected;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'vi_VN', // Bạn có thể điều chỉnh cho phù hợp với ứng dụng
      firstDay: DateTime.utc(2000),
      lastDay: DateTime.utc(2100),
      focusedDay: focusedDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onPageChanged: (focusedDay) {
        if (onPageChanged != null) onPageChanged!(focusedDay);
      },
      onDaySelected: (mySelectedDay, myFocusedDay) {
        if (!isSameDay(selectedDay, mySelectedDay) &&
            isSameMonth(focusedDay, mySelectedDay) &&
            onDaySelected != null) {
          onDaySelected!(mySelectedDay, myFocusedDay);
        }
      },
      eventLoader: (day) {
        // Lọc các khoản thu/chi theo ngày
        return expenses != null
            ? expenses!
                .where((expense) => isSameDay(expense.date, day))
                .toList()
            : [];
      },
      calendarStyle: CalendarStyle(
        tableBorder: TableBorder(
          bottom: customBorderSide(),
          horizontalInside: customBorderSide(),
          verticalInside: customBorderSide(),
          left: customBorderSide(),
          right: customBorderSide(),
          top: customBorderSide(),
        ),
        isTodayHighlighted: true,
        cellPadding: const EdgeInsets.all(0),
        selectedDecoration: BoxDecoration(
          color: const Color.fromRGBO(104, 214, 157, 1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        selectedTextStyle: const TextStyle(
          color: Color.fromRGBO(64, 29, 131, 1),
          fontWeight: FontWeight.bold,
        ),
        todayDecoration: BoxDecoration(
          color: const Color.fromRGBO(217, 217, 217, 1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        todayTextStyle: const TextStyle(
          color: Color.fromRGBO(194, 0, 0, 1),
        ),
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        weekendDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(6.0),
        ),
        outsideDaysVisible: true,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        rightChevronPadding: const EdgeInsets.all(5),
        leftChevronPadding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        headerPadding: const EdgeInsets.all(0),
        headerMargin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black54,
        ),
        titleTextFormatter: (date, locale) {
          // Custom date format for the title
          return "Tháng ${DateFormat('M').format(date)}-${DateFormat('yyyy').format(date)}";
        },
      ),
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, focusedDay) {
          if (day.month != focusedDay.month || day.year != focusedDay.year) {
            return const SizedBox.shrink();
          }
          return null;
        },
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty && isSameMonth(focusedDay, day)) {
            return Positioned(
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (isSameDay(day, selectedDay) ||
                          isSameDay(day, DateTime.now()))
                      ? const Color.fromRGBO(255, 146, 64, 1)
                      : const Color.fromRGBO(109, 36, 207, 1),
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Text(
                  events.length.toString(),
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 169, 1),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
        dowBuilder: (context, day) {
          if (day.weekday == DateTime.sunday ||
              day.weekday == DateTime.saturday) {
            return Center(
              child: Text(
                DateFormat.E().format(day),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
