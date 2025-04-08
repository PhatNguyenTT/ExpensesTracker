import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/utils/currency_formatter.dart';

class ViewAllExpenses extends StatefulWidget {
  final List<Expense> expenses;

  const ViewAllExpenses({super.key, required this.expenses});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Sắp xếp theo ngày tăng dần
    final sortedExpenses = [...widget.expenses]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Lọc theo tên (nếu có)
    final filtered = sortedExpenses.where((expense) {
      return expense.category.name
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả giao dịch'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên danh mục...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có giao dịch nào.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, i) {
                      final expense = filtered[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: expense.category.color,
                          radius: 24,
                          child: Image.asset(
                            'assets/${expense.category.icon}.png',
                            scale: 2,
                          ),
                        ),
                        title: Text(
                          expense.category.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                            Text(DateFormat('dd/MM/yyyy').format(expense.date)),
                        trailing: Text(
                          formatSignedCurrency(expense.category.totalExpenses),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                getAmountColor(expense.category.totalExpenses),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
