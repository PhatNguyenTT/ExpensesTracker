import '../entities/daily_summary_entity.dart';

/// Thống kê tổng hợp theo ngày
class DailySummary {
  String summaryId; // Format: "YYYY-MM-DD" (VD: "2024-03-15")
  DateTime date;
  int totalIncome; // Tổng thu nhập trong ngày
  int totalExpense; // Tổng chi tiêu trong ngày
  int balance; // Số dư = totalIncome - totalExpense
  int transactionCount; // Số lượng giao dịch trong ngày
  DateTime lastUpdated; // Lần cập nhật cuối

  DailySummary({
    required this.summaryId,
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  static final empty = DailySummary(
    summaryId: '',
    date: DateTime.now(),
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    transactionCount: 0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId từ date
  static String generateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DailySummary copyWith({
    String? summaryId,
    DateTime? date,
    int? totalIncome,
    int? totalExpense,
    int? balance,
    int? transactionCount,
    DateTime? lastUpdated,
  }) {
    return DailySummary(
      summaryId: summaryId ?? this.summaryId,
      date: date ?? this.date,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  DailySummaryEntity toEntity() {
    return DailySummaryEntity(
      summaryId: summaryId,
      date: date,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      lastUpdated: lastUpdated,
    );
  }

  static DailySummary fromEntity(DailySummaryEntity entity) {
    return DailySummary(
      summaryId: entity.summaryId,
      date: entity.date,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      transactionCount: entity.transactionCount,
      lastUpdated: entity.lastUpdated,
    );
  }
}
