class MonthlySummaryEntity {
  String summaryId;
  int year;
  int month;
  int totalIncome;
  int totalExpense;
  int balance;
  int transactionCount;
  DateTime lastUpdated;

  MonthlySummaryEntity({
    required this.summaryId,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  Map<String, Object?> toDocument() {
    return {
      'summaryId': summaryId,
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static MonthlySummaryEntity fromDocument(Map<String, dynamic> doc) {
    return MonthlySummaryEntity(
      summaryId: doc['summaryId'] as String,
      year: doc['year'] as int,
      month: doc['month'] as int,
      totalIncome: doc['totalIncome'] as int,
      totalExpense: doc['totalExpense'] as int,
      balance: doc['balance'] as int,
      transactionCount: doc['transactionCount'] as int,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(doc['lastUpdated'] as int),
    );
  }
}
