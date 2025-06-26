import '../entities/daily_summary_entity.dart';

/// Thống kê tổng hợp theo ngày cho từng ví
class DailySummary {
  String summaryId; // Format: "walletId_YYYY-MM-DD"
  String walletId; // 👈 Thêm ID của ví
  DateTime date;
  int totalIncome; // Tổng thu nhập trong ngày
  int totalExpense; // Tổng chi tiêu trong ngày
  int balance; // Số dư = totalIncome - totalExpense
  int transactionCount; // Số lượng giao dịch trong ngày
  DateTime lastUpdated; // Lần cập nhật cuối

  DailySummary({
    required this.summaryId,
    required this.walletId, // 👈
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  static final empty = DailySummary(
    summaryId: '',
    walletId: '', // 👈
    date: DateTime.now(),
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    transactionCount: 0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId từ walletId và date
  static String generateId(String walletId, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${walletId}_$dateStr';
  }

  DailySummary copyWith({
    String? summaryId,
    String? walletId, // 👈
    DateTime? date,
    int? totalIncome,
    int? totalExpense,
    int? balance,
    int? transactionCount,
    DateTime? lastUpdated,
  }) {
    return DailySummary(
      summaryId: summaryId ?? this.summaryId,
      walletId: walletId ?? this.walletId, // 👈
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
      walletId: walletId, // 👈
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
      walletId: entity.walletId, // 👈
      date: entity.date,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      transactionCount: entity.transactionCount,
      lastUpdated: entity.lastUpdated,
    );
  }
}
