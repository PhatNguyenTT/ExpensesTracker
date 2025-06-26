import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/entities.dart';

import '../models/models.dart';

class ExpenseEntity {
  final String expenseId;
  final Category category;
  final DateTime date;
  final int amount;
  final String note; // Thêm ghi chú

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    required this.note,
  });

  Map<String, dynamic> toDocument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDocument(),
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'note': note, // ✅ ghi chú
    };
  }

  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      expenseId: doc['expenseId'] as String,
      category: Category.fromEntity(
        CategoryEntity.fromDocument(doc['category']),
      ),
      date: (doc['date'] as Timestamp).toDate(),
      amount: doc['amount'] as int,
      note: doc['note'] as String? ?? '', // fallback nếu null
    );
  }
}
