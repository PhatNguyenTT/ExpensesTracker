import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/screens/stats/chart/pie_chart_with_badge.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/utils/icon_mapper.dart';

class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const StatsScreen(this.expenses, {super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int selectedView = 0; // 0 = Tháng, 1 = Năm
  int selectedType = 0; // 0 = Chi tiêu, 1 = Thu nhập
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isExpense = selectedType == 0;

    final filteredExpenses = widget.expenses
        .where((e) {
          final isSamePeriod = selectedView == 0
              ? (e.date.month == selectedDate.month &&
                  e.date.year == selectedDate.year)
              : (e.date.year == selectedDate.year);

          final isMatchingType = isExpense
              ? e.category.type == tt.TransactionType.expense
              : e.category.type == tt.TransactionType.income;

          return isSamePeriod && isMatchingType;
        })
        .map((e) => e.copyWith(
              category: e.category
                  .copyWith(), // ⚠️ Clone category để tránh liên kết tham chiếu
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodTab(0, 'Tháng'),
                const SizedBox(width: 8),
                _buildPeriodTab(1, 'Năm'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedView == 0
                          ? DateTime(selectedDate.year, selectedDate.month - 1)
                          : DateTime(selectedDate.year - 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  selectedView == 0
                      ? DateFormat('MM/yyyy').format(selectedDate)
                      : DateFormat('yyyy').format(selectedDate),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDate = selectedView == 0
                          ? DateTime(selectedDate.year, selectedDate.month + 1)
                          : DateTime(selectedDate.year + 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTypeTab(0, 'Chi tiêu'),
                const SizedBox(width: 12),
                _buildTypeTab(1, 'Thu nhập'),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: 1.5,
                child: PieChartWithBadge(expenses: filteredExpenses),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, i) {
                  final e = filteredExpenses[i];
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: e.category.color,
                              child: Icon(
                                IconMapper.getIcon(e.category.icon) ??
                                    Icons.category,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(e.date),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                if (e.note != null && e.note!.isNotEmpty)
                                  Text(
                                    e.note!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          '${e.amount > 0 ? '+' : ''}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(e.amount)}',
                          style: TextStyle(
                            color: e.amount < 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(int index, String label) {
    final isSelected = selectedView == index;
    return GestureDetector(
      onTap: () => setState(() => selectedView = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surfaceVariant
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(int index, String label) {
    final isSelected = selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = index),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
