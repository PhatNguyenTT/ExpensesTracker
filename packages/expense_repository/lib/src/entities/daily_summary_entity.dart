import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity để lưu trữ thống kê ngày trên Firestore
class DailySummaryEntity {
  String summaryId;
  String walletId;
  DateTime date;
  int totalIncome;
  int totalExpense;
  int balance;
  int transactionCount;
  DateTime lastUpdated;

  DailySummaryEntity({
    required this.summaryId,
    required this.walletId,
    required this.date,
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
      'date': Timestamp.fromDate(date),
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'transactionCount': transactionCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static DailySummaryEntity fromJson(Map<String, dynamic> json) {
    return DailySummaryEntity(
      summaryId: json['summaryId'] as String,
      walletId: json['walletId'] as String,
      date: (json['date'] as Timestamp).toDate(),
      totalIncome: json['totalIncome'] as int,
      totalExpense: json['totalExpense'] as int,
      balance: json['balance'] as int,
      transactionCount: json['transactionCount'] as int,
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
