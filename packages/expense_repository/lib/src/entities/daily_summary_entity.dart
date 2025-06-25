class DailySummaryEntity {
  String summaryId;
  DateTime date;
  int totalIncome;
  int totalExpense;
  int balance;
  int transactionCount;
  DateTime lastUpdated;

  DailySummaryEntity({
    required this.summaryId,
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  Map<String, Object?> toDocument() {
    return {
      'summaryId': summaryId,
      'date': date.millisecondsSinceEpoch,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static DailySummaryEntity fromDocument(Map<String, dynamic> doc) {
    return DailySummaryEntity(
      summaryId: doc['summaryId'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(doc['date'] as int),
      totalIncome: doc['totalIncome'] as int,
      totalExpense: doc['totalExpense'] as int,
      balance: doc['balance'] as int,
      transactionCount: doc['transactionCount'] as int,
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(doc['lastUpdated'] as int),
    );
  }
}
