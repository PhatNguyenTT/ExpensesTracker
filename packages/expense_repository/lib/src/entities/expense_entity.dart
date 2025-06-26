import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/src/entities/category_entity.dart';
import 'package:expense_repository/src/models/category.dart';

class ExpenseEntity {
  String expenseId;
  String walletId;
  Category category;
  DateTime date;
  int amount;
  String note;

  ExpenseEntity({
    required this.expenseId,
    required this.walletId,
    required this.category,
    required this.date,
    required this.amount,
    required this.note,
  });

  Map<String, Object?> toJson() {
    return {
      'expenseId': expenseId,
      'walletId': walletId,
      'category': category.toEntity().toJson(),
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'note': note,
    };
  }

  static ExpenseEntity fromJson(Map<String, dynamic> json) {
    return ExpenseEntity(
      expenseId: json['expenseId'] as String,
      walletId: json['walletId'] as String,
      category: Category.fromEntity(
          CategoryEntity.fromJson(json['category'] as Map<String, dynamic>)),
      date: (json['date'] as Timestamp).toDate(),
      amount: json['amount'] as int,
      note: json['note'] as String,
    );
  }
}
