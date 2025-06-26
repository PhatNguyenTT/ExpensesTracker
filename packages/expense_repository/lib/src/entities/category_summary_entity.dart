import 'package:cloud_firestore/cloud_firestore.dart';

/// Entity để lưu trữ thống kê danh mục trên Firestore
class CategorySummaryEntity {
  String summaryId;
  String walletId;
  String categoryId;
  String categoryName;
  String type; // 'income' hoặc 'expense'
  int year;
  int? month;
  int totalAmount;
  int transactionCount;
  double averageAmount;
  DateTime lastUpdated;

  CategorySummaryEntity({
    required this.summaryId,
    required this.walletId,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.year,
    this.month,
    required this.totalAmount,
    required this.transactionCount,
    required this.averageAmount,
    required this.lastUpdated,
  });

  Map<String, Object?> toJson() {
    return {
      'summaryId': summaryId,
      'walletId': walletId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type,
      'year': year,
      'month': month,
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'averageAmount': averageAmount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static CategorySummaryEntity fromJson(Map<String, dynamic> json) {
    return CategorySummaryEntity(
      summaryId: json['summaryId'] as String,
      walletId: json['walletId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      type: json['type'] as String,
      year: json['year'] as int,
      month: json['month'] as int?,
      totalAmount: json['totalAmount'] as int,
      transactionCount: json['transactionCount'] as int,
      averageAmount: (json['averageAmount'] as num).toDouble(),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
