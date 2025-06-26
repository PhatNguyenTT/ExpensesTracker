import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity để lưu trữ thống kê năm trên Firestore
class YearlySummaryEntity {
  String summaryId;
  String walletId;
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
    required this.walletId,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.averageMonthlyIncome,
    required this.averageMonthlyExpense,
    required this.lastUpdated,
  });

  Map<String, Object?> toJson() {
    return {
      'summaryId': summaryId,
      'walletId': walletId,
      'year': year,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'averageMonthlyIncome': averageMonthlyIncome,
      'averageMonthlyExpense': averageMonthlyExpense,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static YearlySummaryEntity fromJson(Map<String, dynamic> json) {
    return YearlySummaryEntity(
      summaryId: json['summaryId'] as String,
      walletId: json['walletId'] as String,
      year: json['year'] as int,
      totalIncome: json['totalIncome'] as int,
      totalExpense: json['totalExpense'] as int,
      balance: json['balance'] as int,
      transactionCount: json['transactionCount'] as int,
      averageMonthlyIncome: json['averageMonthlyIncome'] as double,
      averageMonthlyExpense: json['averageMonthlyExpense'] as double,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
