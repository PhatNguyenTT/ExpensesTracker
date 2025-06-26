import '../entities/overall_summary_entity.dart';

/// Thống kê tổng hợp toàn thời gian cho từng ví
class OverallSummary {
  String summaryId; // ID chính là walletId
  int totalIncome; // Tổng thu nhập của ví
  int totalExpense; // Tổng chi tiêu của ví
  int balance; // Số dư tổng của ví = totalIncome - totalExpense
  int totalTransactionCount; // Tổng số giao dịch của ví
  DateTime firstTransactionDate; // Ngày giao dịch đầu tiên của ví
  DateTime lastTransactionDate; // Ngày giao dịch cuối cùng của ví
  DateTime lastUpdated; // Lần cập nhật cuối

  OverallSummary({
    required this.summaryId,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.totalTransactionCount,
    required this.firstTransactionDate,
    required this.lastTransactionDate,
    required this.lastUpdated,
  });

  static OverallSummary empty(String walletId) => OverallSummary(
        summaryId: walletId,
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
        totalTransactionCount: 0,
        firstTransactionDate: DateTime.now(),
        lastTransactionDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

  /// Fixed ID cho overall summary
  static String generateId() => 'overall';

  OverallSummary copyWith({
    String? summaryId,
    int? totalIncome,
    int? totalExpense,
    int? balance,
    int? totalTransactionCount,
    DateTime? firstTransactionDate,
    DateTime? lastTransactionDate,
    DateTime? lastUpdated,
  }) {
    return OverallSummary(
      summaryId: summaryId ?? this.summaryId,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      totalTransactionCount:
          totalTransactionCount ?? this.totalTransactionCount,
      firstTransactionDate: firstTransactionDate ?? this.firstTransactionDate,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  OverallSummaryEntity toEntity() {
    return OverallSummaryEntity(
      summaryId: summaryId,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      totalTransactionCount: totalTransactionCount,
      firstTransactionDate: firstTransactionDate,
      lastTransactionDate: lastTransactionDate,
      lastUpdated: lastUpdated,
    );
  }

  static OverallSummary fromEntity(OverallSummaryEntity entity) {
    return OverallSummary(
      summaryId: entity.summaryId,
      totalIncome: entity.totalIncome,
      totalExpense: entity.totalExpense,
      balance: entity.balance,
      totalTransactionCount: entity.totalTransactionCount,
      firstTransactionDate: entity.firstTransactionDate,
      lastTransactionDate: entity.lastTransactionDate,
      lastUpdated: entity.lastUpdated,
    );
  }
}
