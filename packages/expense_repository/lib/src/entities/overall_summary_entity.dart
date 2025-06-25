class OverallSummaryEntity {
  String summaryId;
  int totalIncome;
  int totalExpense;
  int balance;
  int totalTransactionCount;
  DateTime firstTransactionDate;
  DateTime lastTransactionDate;
  DateTime lastUpdated;

  OverallSummaryEntity({
    required this.summaryId,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.totalTransactionCount,
    required this.firstTransactionDate,
    required this.lastTransactionDate,
    required this.lastUpdated,
  });

  Map<String, Object?> toDocument() {
    return {
      'summaryId': summaryId,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'totalTransactionCount': totalTransactionCount,
      'firstTransactionDate': firstTransactionDate.millisecondsSinceEpoch,
      'lastTransactionDate': lastTransactionDate.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static OverallSummaryEntity fromDocument(Map<String, dynamic> doc) {
    return OverallSummaryEntity(
      summaryId: doc['summaryId'] as String,
      totalIncome: doc['totalIncome'] as int,
      totalExpense: doc['totalExpense'] as int,
      balance: doc['balance'] as int,
      totalTransactionCount: doc['totalTransactionCount'] as int,
      firstTransactionDate: DateTime.fromMillisecondsSinceEpoch(
          doc['firstTransactionDate'] as int),
      lastTransactionDate: DateTime.fromMillisecondsSinceEpoch(
          doc['lastTransactionDate'] as int),
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(doc['lastUpdated'] as int),
    );
  }
}
