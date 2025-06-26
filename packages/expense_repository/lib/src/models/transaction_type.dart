enum TransactionType {
  income,
  expense,
}

extension TransactionTypeExtension on TransactionType {
  String get name => this == TransactionType.income ? 'Thu nhập' : 'Chi tiêu';

  static TransactionType fromString(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Unknown transaction type: $value');
    }
  }

  String toJson() => toString().split('.').last;
}
