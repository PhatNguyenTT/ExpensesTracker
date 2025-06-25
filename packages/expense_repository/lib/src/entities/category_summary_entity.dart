class CategorySummaryEntity {
  String summaryId;
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

  Map<String, Object?> toDocument() {
    return {
      'summaryId': summaryId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'type': type,
      'year': year,
      'month': month,
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'averageAmount': averageAmount,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  static CategorySummaryEntity fromDocument(Map<String, dynamic> doc) {
    return CategorySummaryEntity(
      summaryId: doc['summaryId'] as String,
      categoryId: doc['categoryId'] as String,
      categoryName: doc['categoryName'] as String,
      type: doc['type'] as String,
      year: doc['year'] as int,
      month: doc['month'] as int?,
      totalAmount: doc['totalAmount'] as int,
      transactionCount: doc['transactionCount'] as int,
      averageAmount: (doc['averageAmount'] as num).toDouble(),
      lastUpdated:
          DateTime.fromMillisecondsSinceEpoch(doc['lastUpdated'] as int),
    );
  }
}
