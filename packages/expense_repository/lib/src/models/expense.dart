import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

class Expense {
  String expenseId;
  String walletId;
  Category category;
  DateTime date;
  int amount;
  String? note;

  Expense({
    required this.expenseId,
    required this.walletId,
    required this.category,
    required this.date,
    required this.amount,
    this.note,
  });

  static final empty = Expense(
    expenseId: '',
    walletId: '',
    category: Category.empty,
    date: DateTime.now(),
    amount: 0,
    note: null,
  );

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      walletId: walletId,
      category: category,
      date: date,
      amount: amount,
      note: note ?? '',
    );
  }

  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      expenseId: entity.expenseId,
      walletId: entity.walletId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount,
      note: entity.note.isEmpty ? null : entity.note,
    );
  }

  // ✅ Thêm phương thức copyWith
  Expense copyWith({
    String? expenseId,
    String? walletId,
    Category? category,
    DateTime? date,
    int? amount,
    String? note,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      walletId: walletId ?? this.walletId,
      category: category ?? this.category,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
