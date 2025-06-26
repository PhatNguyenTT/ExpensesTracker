import '../entities/monthly_summary_entity.dart';

/// Thống kê tổng hợp theo tháng
class MonthlySummary {
  String summaryId; // Format: "YYYY-MM" (VD: "2024-03")
  int year;
  int month;
  int totalIncome; // Tổng thu nhập trong tháng
  int totalExpense; // Tổng chi tiêu trong tháng
  int balance; // Số dư = totalIncome - totalExpense
  int transactionCount; // Số lượng giao dịch trong tháng
  DateTime lastUpdated; // Lần cập nhật cuối

  MonthlySummary({
    required this.summaryId,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.lastUpdated,
  });

  static final empty = MonthlySummary(
    summaryId: '',
    year: DateTime.now().year,
    month: DateTime.now().month,
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    transactionCount: 0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId từ year và month
  static String generateId(int year, int month) {
    return '${year.toString()}-${month.toString().padLeft(2, '0')}';
  }

  MonthlySummary copyWith({
    String? summaryId,
    int? year,
    int? month,
    int? totalIncome,
    int? totalExpense,
    int? balance,
    int? transactionCount,
    DateTime? lastUpdated,
  }) {
    return MonthlySummary(
      summaryId: summaryId ?? this.summaryId,
      year: year ?? this.year,
      month: month ?? this.month,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  MonthlySummaryEntity toEntity() {
    return MonthlySummaryEntity(
      summaryId: summaryId,
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      lastUpdated: lastUpdated,
    );
  }

  static MonthlySummary fromEntity(MonthlySummaryEntity entity) {
    return MonthlySummary(
      summaryId: entity.summaryId,
      year: entity.year,
      month: entity.month,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      transactionCount: entity.transactionCount,
      lastUpdated: entity.lastUpdated,
    );
  }
}
