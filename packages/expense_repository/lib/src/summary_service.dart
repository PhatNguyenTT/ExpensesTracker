import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'models/transaction_type.dart';

/// Service để tính toán summaries từ raw expenses data
class SummaryService {
  /// Tính toán OverallSummary từ danh sách expenses của một ví
  static OverallSummary calculateOverallSummary(
      List<Expense> expenses, String walletId) {
    if (expenses.isEmpty) {
      return OverallSummary.empty(walletId)
          .copyWith(lastUpdated: DateTime.now());
    }

    int totalIncome = 0;
    int totalExpense = 0;
    DateTime? earliest;
    DateTime? latest;

    for (final expense in expenses) {
      if (expense.category.type == TransactionType.income) {
        totalIncome += expense.amount;
      } else {
        totalExpense += expense.amount;
      }

      if (earliest == null || expense.date.isBefore(earliest)) {
        earliest = expense.date;
      }
      if (latest == null || expense.date.isAfter(latest)) {
        latest = expense.date;
      }
    }

    return OverallSummary(
      summaryId: walletId,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      totalTransactionCount: expenses.length,
      firstTransactionDate: earliest ?? DateTime.now(),
      lastTransactionDate: latest ?? DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Tính toán số dư thực tại một thời điểm cụ thể cho một ví
  static int calculateRealBalanceAtDate(
      List<Expense> allExpenses, DateTime date, Wallet? wallet) {
    final expensesUpToDate = allExpenses
        .where((e) => e.date.isBefore(date) || isSameDay(e.date, date))
        .toList();

    final stats = ExpenseStats.fromExpenses(expensesUpToDate);
    return stats.realBalance(wallet);
  }

  /// Kiểm tra xem hai ngày có cùng ngày không
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Tính toán MonthlySummary từ danh sách expenses của tháng đó cho một ví
  static MonthlySummary calculateMonthlySummary(
      List<Expense> monthlyExpenses, String walletId, int year, int month) {
    int totalIncome = 0;
    int totalExpense = 0;

    for (final expense in monthlyExpenses) {
      if (expense.category.type == TransactionType.income) {
        totalIncome += expense.amount;
      } else {
        totalExpense += expense.amount;
      }
    }

    return MonthlySummary(
      summaryId: MonthlySummary.generateId(walletId, year, month),
      walletId: walletId,
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      transactionCount: monthlyExpenses.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Tính toán YearlySummary từ danh sách expenses của năm đó cho một ví
  static YearlySummary calculateYearlySummary(
      List<Expense> yearlyExpenses, String walletId, int year) {
    int totalIncome = 0;
    int totalExpense = 0;

    for (final expense in yearlyExpenses) {
      if (expense.category.type == TransactionType.income) {
        totalIncome += expense.amount;
      } else {
        totalExpense += expense.amount;
      }
    }

    return YearlySummary(
      summaryId: YearlySummary.generateId(walletId, year),
      walletId: walletId,
      year: year,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      transactionCount: yearlyExpenses.length,
      averageMonthlyIncome: totalIncome / 12.0,
      averageMonthlyExpense: totalExpense / 12.0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Tính toán DailySummary từ danh sách expenses của ngày đó cho một ví
  static DailySummary calculateDailySummary(
      List<Expense> dailyExpenses, String walletId, DateTime date) {
    int totalIncome = 0;
    int totalExpense = 0;

    for (final expense in dailyExpenses) {
      if (expense.category.type == TransactionType.income) {
        totalIncome += expense.amount;
      } else {
        totalExpense += expense.amount;
      }
    }

    return DailySummary(
      summaryId: DailySummary.generateId(walletId, date),
      walletId: walletId,
      date: date,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      transactionCount: dailyExpenses.length,
      lastUpdated: DateTime.now(),
    );
  }

  /// Tính toán CategorySummary từ danh sách expenses của category đó cho một ví
  static CategorySummary calculateCategorySummary(
      List<Expense> categoryExpenses,
      String walletId,
      String categoryId,
      String categoryName,
      TransactionType type,
      int year,
      int? month) {
    int totalAmount = categoryExpenses.fold(0, (sum, e) => sum + e.amount);
    double averageAmount =
        categoryExpenses.isEmpty ? 0.0 : totalAmount / categoryExpenses.length;

    String summaryId = month != null
        ? CategorySummary.generateMonthlyId(walletId, categoryId, year, month)
        : CategorySummary.generateYearlyId(walletId, categoryId, year);

    return CategorySummary(
      summaryId: summaryId,
      walletId: walletId,
      categoryId: categoryId,
      categoryName: categoryName,
      type: type,
      year: year,
      month: month,
      totalAmount: totalAmount,
      transactionCount: categoryExpenses.length,
      averageAmount: averageAmount,
      lastUpdated: DateTime.now(),
    );
  }

  /// Lọc expenses theo tháng
  static List<Expense> filterByMonth(
      List<Expense> expenses, int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  /// Lọc expenses theo năm
  static List<Expense> filterByYear(List<Expense> expenses, int year) {
    return expenses.where((e) => e.date.year == year).toList();
  }

  /// Lọc expenses theo ngày
  static List<Expense> filterByDate(List<Expense> expenses, DateTime date) {
    return expenses
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList();
  }

  /// Lọc expenses theo category
  static List<Expense> filterByCategory(
      List<Expense> expenses, String categoryId) {
    return expenses.where((e) => e.category.categoryId == categoryId).toList();
  }

  /// Group expenses theo category
  static Map<String, List<Expense>> groupByCategory(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};

    for (final expense in expenses) {
      final key = expense.category.categoryId;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(expense);
    }

    return grouped;
  }

  /// Tính toán tất cả CategorySummaries cho một tháng của một ví
  static List<CategorySummary> calculateAllCategorySummariesForMonth(
      List<Expense> expenses, String walletId, int year, int month) {
    final monthlyExpenses = filterByMonth(expenses, year, month);
    final grouped = groupByCategory(monthlyExpenses);

    return grouped.entries.map((entry) {
      final categoryExpenses = entry.value;
      final firstExpense = categoryExpenses.first;

      return calculateCategorySummary(
        categoryExpenses,
        walletId,
        firstExpense.category.categoryId,
        firstExpense.category.name,
        firstExpense.category.type,
        year,
        month,
      );
    }).toList();
  }

  /// Tính toán tất cả CategorySummaries cho một năm của một ví
  static List<CategorySummary> calculateAllCategorySummariesForYear(
      List<Expense> expenses, String walletId, int year) {
    final yearlyExpenses = filterByYear(expenses, year);
    final grouped = groupByCategory(yearlyExpenses);

    return grouped.entries.map((entry) {
      final categoryExpenses = entry.value;
      final firstExpense = categoryExpenses.first;

      return calculateCategorySummary(
        categoryExpenses,
        walletId,
        firstExpense.category.categoryId,
        firstExpense.category.name,
        firstExpense.category.type,
        year,
        null, // null = yearly summary
      );
    }).toList();
  }
}
