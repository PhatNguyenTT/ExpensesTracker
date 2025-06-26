class YearlySummaryEntity {
  String summaryId;
  int year;
  int totalIncome;
  int totalExpense;
  int balance;
  int transactionCount;
  double averageMonthlyIncome;
  double averageMonthlyExpense;
  DateTime lastUpdated;

  YearlySummaryEntity({
    required this.summaryId,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.averageMonthlyIncome,
    required this.averageMonthlyExpense,
    required this.lastUpdated,
  });

  Map<String, Object?> toDocument() {
    return {
      'summaryId': summaryId,
      'year': year,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'averageMonthlyIncome': averageMonthlyIncome,
      'averageMonthlyExpense': averageMonthlyExpense,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static YearlySummaryEntity fromDocument(Map<String, dynamic> doc) {
    return YearlySummaryEntity(
      summaryId: doc['summaryId'] as String,
      year: doc['year'] as int,
      totalIncome: doc['totalIncome'] as int,
      totalExpense: doc['totalExpense'] as int,
      balance: doc['balance'] as int,
      transactionCount: doc['transactionCount'] as int,
      averageMonthlyIncome: (doc['averageMonthlyIncome'] as num).toDouble(),
      averageMonthlyExpense: (doc['averageMonthlyExpense'] as num).toDouble(),
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(doc['lastUpdated'] as int),
    );
  }
}
