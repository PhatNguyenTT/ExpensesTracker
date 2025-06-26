import '../entities/monthly_summary_entity.dart';

/// Thống kê tổng hợp theo tháng cho từng ví
class MonthlySummary {
  String summaryId; // Format: "walletId_YYYY-MM"
  String walletId; // 👈 Thêm ID của ví
  int year;
  int month;
  int totalIncome; // Tổng thu nhập trong tháng
  int totalExpense; // Tổng chi tiêu trong tháng
  int balance; // Số dư = totalIncome - totalExpense
  int transactionCount; // Số lượng giao dịch trong tháng
  DateTime lastUpdated; // Lần cập nhật cuối

  MonthlySummary({
    required this.summaryId,
    required this.walletId, // 👈
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
    walletId: '', // 👈
    year: DateTime.now().year,
    month: DateTime.now().month,
    totalIncome: 0,
    totalExpense: 0,
    balance: 0,
    transactionCount: 0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId từ walletId, year và month
  static String generateId(String walletId, int year, int month) {
    return '${walletId}_${year.toString()}-${month.toString().padLeft(2, '0')}';
  }

  MonthlySummary copyWith({
    String? summaryId,
    String? walletId, // 👈
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
      walletId: walletId ?? this.walletId, // 👈
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
      walletId: walletId, // 👈
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
      walletId: entity.walletId, // 👈
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
