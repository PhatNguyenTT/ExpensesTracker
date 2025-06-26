import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity để lưu trữ thống kê tổng hợp của ví trên Firestore
class OverallSummaryEntity {
  String summaryId; // ID chính là walletId
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

  Map<String, Object?> toJson() {
    return {
      'summaryId': summaryId,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'totalTransactionCount': totalTransactionCount,
      'firstTransactionDate': Timestamp.fromDate(firstTransactionDate),
      'lastTransactionDate': Timestamp.fromDate(lastTransactionDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static OverallSummaryEntity fromJson(Map<String, dynamic> json) {
    return OverallSummaryEntity(
      summaryId: json['summaryId'] as String,
      totalIncome: json['totalIncome'] as int,
      totalExpense: json['totalExpense'] as int,
      balance: json['balance'] as int,
      totalTransactionCount: json['totalTransactionCount'] as int,
      firstTransactionDate:
          (json['firstTransactionDate'] as Timestamp).toDate(),
      lastTransactionDate: (json['lastTransactionDate'] as Timestamp).toDate(),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
