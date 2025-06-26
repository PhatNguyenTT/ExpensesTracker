import '../entities/category_summary_entity.dart';
import 'transaction_type.dart';

/// Thống kê tổng hợp theo danh mục và thời gian cho từng ví
class CategorySummary {
  String
      summaryId; // Format: "walletId_categoryId_YYYY-MM" hoặc "walletId_categoryId_YYYY"
  String walletId; // 👈 Thêm ID của ví
  String categoryId;
  String categoryName;
  TransactionType type;
  int year;
  int? month; // null nếu là thống kê năm
  int totalAmount; // Tổng số tiền
  int transactionCount; // Số lượng giao dịch
  double averageAmount; // Số tiền trung bình mỗi giao dịch
  DateTime lastUpdated; // Lần cập nhật cuối

  CategorySummary({
    required this.summaryId,
    required this.walletId, // 👈
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

  static final empty = CategorySummary(
    summaryId: '',
    walletId: '', // 👈
    categoryId: '',
    categoryName: '',
    type: TransactionType.expense,
    year: DateTime.now().year,
    month: DateTime.now().month,
    totalAmount: 0,
    transactionCount: 0,
    averageAmount: 0.0,
    lastUpdated: DateTime.now(),
  );

  /// Tạo summaryId cho thống kê tháng
  static String generateMonthlyId(
      String walletId, String categoryId, int year, int month) {
    return '${walletId}_${categoryId}_${year.toString()}-${month.toString().padLeft(2, '0')}';
  }

  /// Tạo summaryId cho thống kê năm
  static String generateYearlyId(String walletId, String categoryId, int year) {
    return '${walletId}_${categoryId}_${year.toString()}';
  }

  /// Check xem có phải thống kê tháng không
  bool get isMonthly => month != null;

  /// Check xem có phải thống kê năm không
  bool get isYearly => month == null;

  CategorySummary copyWith({
    String? summaryId,
    String? walletId, // 👈
    String? categoryId,
    String? categoryName,
    TransactionType? type,
    int? year,
    int? month,
    int? totalAmount,
    int? transactionCount,
    double? averageAmount,
    DateTime? lastUpdated,
  }) {
    return CategorySummary(
      summaryId: summaryId ?? this.summaryId,
      walletId: walletId ?? this.walletId, // 👈
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      year: year ?? this.year,
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      averageAmount: averageAmount ?? this.averageAmount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  CategorySummaryEntity toEntity() {
    return CategorySummaryEntity(
      summaryId: summaryId,
      walletId: walletId, // 👈
      categoryId: categoryId,
      categoryName: categoryName,
      type: type.toJson(),
      year: year,
      month: month,
      totalAmount: totalAmount,
      transactionCount: transactionCount,
      averageAmount: averageAmount,
      lastUpdated: lastUpdated,
    );
  }

  static CategorySummary fromEntity(CategorySummaryEntity entity) {
    return CategorySummary(
      summaryId: entity.summaryId,
      walletId: entity.walletId, // 👈
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      type: TransactionTypeExtension.fromString(entity.type),
      year: entity.year,
      month: entity.month,
      totalAmount: entity.totalAmount,
      transactionCount: entity.transactionCount,
      averageAmount: entity.averageAmount,
      lastUpdated: entity.lastUpdated,
    );
  }
}
