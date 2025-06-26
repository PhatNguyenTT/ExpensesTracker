import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity để lưu trữ thống kê tháng trên Firestore
class MonthlySummaryEntity {
  String summaryId;
  String walletId;
  int year;
  int month;
  int totalIncome;
  int totalExpense;
  int balance;
  int transactionCount;
  DateTime lastUpdated;

  MonthlySummaryEntity({
    required this.summaryId,
    required this.walletId,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  Map<String, Object?> toJson() {
    return {
      'summaryId': summaryId,
      'walletId': walletId,
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static MonthlySummaryEntity fromJson(Map<String, dynamic> json) {
    return MonthlySummaryEntity(
      summaryId: json['summaryId'] as String,
      walletId: json['walletId'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      totalIncome: json['totalIncome'] as int,
      totalExpense: json['totalExpense'] as int,
      balance: json['balance'] as int,
      transactionCount: json['transactionCount'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
