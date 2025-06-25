import '../entities/yearly_summary_entity.dart';

/// Thống kê tổng hợp theo năm
class YearlySummary {
  String summaryId; // Format: "YYYY" (VD: "2024")
  int year;
  int totalIncome; // Tổng thu nhập trong năm
  int totalExpense; // Tổng chi tiêu trong năm
  int balance; // Số dư = totalIncome - totalExpense
  int transactionCount; // Số lượng giao dịch trong năm
  double averageMonthlyIncome; // Thu nhập trung bình hàng tháng
  double averageMonthlyExpense; // Chi tiêu trung bình hàng tháng
  DateTime lastUpdated; // Lần cập nhật cuối

  YearlySummary({
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

  static final empty = YearlySummary(
    summaryId: '',
    year: DateTime.now().year,
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    transactionCount: 0,
    averageMonthlyIncome: 0.0,
    averageMonthlyExpense: 0.0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId từ year
  static String generateId(int year) {
    return year.toString();
  }

  YearlySummary copyWith({
    String? summaryId,
    int? year,
    int? totalIncome,
    int? totalExpense,
    int? balance,
    int? transactionCount,
    double? averageMonthlyIncome,
    double? averageMonthlyExpense,
    DateTime? lastUpdated,
  }) {
    return YearlySummary(
      summaryId: summaryId ?? this.summaryId,
      year: year ?? this.year,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      averageMonthlyIncome: averageMonthlyIncome ?? this.averageMonthlyIncome,
      averageMonthlyExpense:
          averageMonthlyExpense ?? this.averageMonthlyExpense,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  YearlySummaryEntity toEntity() {
    return YearlySummaryEntity(
      summaryId: summaryId,
      year: year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      transactionCount: transactionCount,
      averageMonthlyIncome: averageMonthlyIncome,
      averageMonthlyExpense: averageMonthlyExpense,
      lastUpdated: lastUpdated,
    );
  }

  static YearlySummary fromEntity(YearlySummaryEntity entity) {
    return YearlySummary(
      summaryId: entity.summaryId,
      year: entity.year,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      transactionCount: entity.transactionCount,
      averageMonthlyIncome: entity.averageMonthlyIncome,
      averageMonthlyExpense: entity.averageMonthlyExpense,
      lastUpdated: entity.lastUpdated,
    );
  }
}
