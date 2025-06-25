import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'summary_service.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');

  // ========== SUMMARY COLLECTIONS ==========
  final overallSummaryCollection =
      FirebaseFirestore.instance.collection('overall_summary');
  final monthlySummaryCollection =
      FirebaseFirestore.instance.collection('monthly_summaries');
  final yearlySummaryCollection =
      FirebaseFirestore.instance.collection('yearly_summaries');
  final dailySummaryCollection =
      FirebaseFirestore.instance.collection('daily_summaries');
  final categorySummaryCollection =
      FirebaseFirestore.instance.collection('category_summaries');

  // ========== CATEGORY OPERATIONS ==========
  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
      return await categoryCollection.get().then((value) => value.docs
          .map(
              (e) => Category.fromEntity(CategoryEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== EXPENSE OPERATIONS ==========
  @override
  Future<void> createExpense(Expense expense) async {
    try {
      // 1. Tạo expense
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());

      // 2. Auto-update summaries
      await updateSummariesForExpense(expense);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      return await expenseCollection.get().then((value) => value.docs
          .map((e) => Expense.fromEntity(ExpenseEntity.fromDocument(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      // 1. Lấy expense cũ để so sánh
      final oldExpenseDoc =
          await expenseCollection.doc(expense.expenseId).get();
      Expense? oldExpense;
      if (oldExpenseDoc.exists) {
        oldExpense = Expense.fromEntity(
            ExpenseEntity.fromDocument(oldExpenseDoc.data()!));
      }

      // 2. Update expense
      await expenseCollection
          .doc(expense.expenseId)
          .update(expense.toEntity().toDocument());

      // 3. Auto-update summaries
      await updateSummariesForExpense(expense, oldExpense: oldExpense);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      // 1. Lấy expense để update summaries
      final expenseDoc = await expenseCollection.doc(expenseId).get();
      if (expenseDoc.exists) {
        final expense =
            Expense.fromEntity(ExpenseEntity.fromDocument(expenseDoc.data()!));

        // 2. Delete expense
        await expenseCollection.doc(expenseId).delete();

        // 3. Auto-update summaries
        await updateSummariesForExpense(expense, isDelete: true);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== OVERALL SUMMARY ==========
  @override
  Future<OverallSummary> getOverallSummary() async {
    try {
      final doc = await overallSummaryCollection.doc('overall').get();
      if (doc.exists) {
        return OverallSummary.fromEntity(
            OverallSummaryEntity.fromDocument(doc.data()!));
      } else {
        // Nếu chưa có, tính toán từ expenses và tạo mới
        final expenses = await getExpenses();
        final summary = SummaryService.calculateOverallSummary(expenses);
        await updateOverallSummary(summary);
        return summary;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateOverallSummary(OverallSummary summary) async {
    try {
      await overallSummaryCollection
          .doc('overall')
          .set(summary.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== MONTHLY SUMMARY ==========
  @override
  Future<MonthlySummary?> getMonthlySummary(int year, int month) async {
    try {
      final summaryId = MonthlySummary.generateId(year, month);
      final doc = await monthlySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return MonthlySummary.fromEntity(
            MonthlySummaryEntity.fromDocument(doc.data()!));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MonthlySummary>> getMonthlyRangeSummary(
      DateTime startDate, DateTime endDate) async {
    try {
      final startId =
          MonthlySummary.generateId(startDate.year, startDate.month);
      final endId = MonthlySummary.generateId(endDate.year, endDate.month);

      final snapshot = await monthlySummaryCollection
          .where('summaryId', isGreaterThanOrEqualTo: startId)
          .where('summaryId', isLessThanOrEqualTo: endId)
          .get();

      return snapshot.docs
          .map((doc) => MonthlySummary.fromEntity(
              MonthlySummaryEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> upsertMonthlySummary(MonthlySummary summary) async {
    try {
      await monthlySummaryCollection
          .doc(summary.summaryId)
          .set(summary.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== YEARLY SUMMARY ==========
  @override
  Future<YearlySummary?> getYearlySummary(int year) async {
    try {
      final summaryId = YearlySummary.generateId(year);
      final doc = await yearlySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return YearlySummary.fromEntity(
            YearlySummaryEntity.fromDocument(doc.data()!));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<YearlySummary>> getYearlyRangeSummary(
      int startYear, int endYear) async {
    try {
      final snapshot = await yearlySummaryCollection
          .where('year', isGreaterThanOrEqualTo: startYear)
          .where('year', isLessThanOrEqualTo: endYear)
          .get();

      return snapshot.docs
          .map((doc) => YearlySummary.fromEntity(
              YearlySummaryEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> upsertYearlySummary(YearlySummary summary) async {
    try {
      await yearlySummaryCollection
          .doc(summary.summaryId)
          .set(summary.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== DAILY SUMMARY ==========
  @override
  Future<DailySummary?> getDailySummary(DateTime date) async {
    try {
      final summaryId = DailySummary.generateId(date);
      final doc = await dailySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return DailySummary.fromEntity(
            DailySummaryEntity.fromDocument(doc.data()!));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<DailySummary>> getDailyRangeSummary(
      DateTime startDate, DateTime endDate) async {
    try {
      final startTimestamp = startDate.millisecondsSinceEpoch;
      final endTimestamp = endDate.millisecondsSinceEpoch;

      final snapshot = await dailySummaryCollection
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThanOrEqualTo: endTimestamp)
          .get();

      return snapshot.docs
          .map((doc) => DailySummary.fromEntity(
              DailySummaryEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> upsertDailySummary(DailySummary summary) async {
    try {
      await dailySummaryCollection
          .doc(summary.summaryId)
          .set(summary.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== CATEGORY SUMMARY ==========
  @override
  Future<List<CategorySummary>> getCategorySummaryByMonth(
      int year, int month) async {
    try {
      final snapshot = await categorySummaryCollection
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();

      return snapshot.docs
          .map((doc) => CategorySummary.fromEntity(
              CategorySummaryEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<CategorySummary>> getCategorySummaryByYear(int year) async {
    try {
      final snapshot = await categorySummaryCollection
          .where('year', isEqualTo: year)
          .where('month', isNull: true) // Yearly summaries have null month
          .get();

      return snapshot.docs
          .map((doc) => CategorySummary.fromEntity(
              CategorySummaryEntity.fromDocument(doc.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<CategorySummary?> getCategorySummary(
      String categoryId, int year, int? month) async {
    try {
      final summaryId = month != null
          ? CategorySummary.generateMonthlyId(categoryId, year, month)
          : CategorySummary.generateYearlyId(categoryId, year);

      final doc = await categorySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return CategorySummary.fromEntity(
            CategorySummaryEntity.fromDocument(doc.data()!));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> upsertCategorySummary(CategorySummary summary) async {
    try {
      await categorySummaryCollection
          .doc(summary.summaryId)
          .set(summary.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== BATCH OPERATIONS ==========
  @override
  Future<void> recalculateAllSummaries() async {
    try {
      log('🔄 Starting recalculation of all summaries...');

      // 1. Lấy tất cả expenses
      final expenses = await getExpenses();
      log('📊 Loaded ${expenses.length} expenses');

      if (expenses.isEmpty) {
        log('⚠️ No expenses found, skipping summary calculation');
        return;
      }

      // 2. Tính toán Overall Summary
      final overallSummary = SummaryService.calculateOverallSummary(expenses);
      await updateOverallSummary(overallSummary);
      log('✅ Updated overall summary');

      // 3. Group theo năm và tháng
      final Map<int, List<Expense>> byYear = {};
      final Map<String, List<Expense>> byMonth = {};
      final Map<String, List<Expense>> byDate = {};

      for (final expense in expenses) {
        // Group by year
        if (!byYear.containsKey(expense.date.year)) {
          byYear[expense.date.year] = [];
        }
        byYear[expense.date.year]!.add(expense);

        // Group by month
        final monthKey = '${expense.date.year}-${expense.date.month}';
        if (!byMonth.containsKey(monthKey)) {
          byMonth[monthKey] = [];
        }
        byMonth[monthKey]!.add(expense);

        // Group by date
        final dateKey = DailySummary.generateId(expense.date);
        if (!byDate.containsKey(dateKey)) {
          byDate[dateKey] = [];
        }
        byDate[dateKey]!.add(expense);
      }

      // 4. Tính toán Yearly Summaries
      for (final entry in byYear.entries) {
        final year = entry.key;
        final yearExpenses = entry.value;

        final yearlySummary =
            SummaryService.calculateYearlySummary(yearExpenses, year);
        await upsertYearlySummary(yearlySummary);

        // Category summaries for year
        final categorySummaries =
            SummaryService.calculateAllCategorySummariesForYear(
                yearExpenses, year);
        for (final catSummary in categorySummaries) {
          await upsertCategorySummary(catSummary);
        }
      }
      log('✅ Updated yearly summaries for ${byYear.length} years');

      // 5. Tính toán Monthly Summaries
      for (final entry in byMonth.entries) {
        final parts = entry.key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final monthExpenses = entry.value;

        final monthlySummary =
            SummaryService.calculateMonthlySummary(monthExpenses, year, month);
        await upsertMonthlySummary(monthlySummary);

        // Category summaries for month
        final categorySummaries =
            SummaryService.calculateAllCategorySummariesForMonth(
                monthExpenses, year, month);
        for (final catSummary in categorySummaries) {
          await upsertCategorySummary(catSummary);
        }
      }
      log('✅ Updated monthly summaries for ${byMonth.length} months');

      // 6. Tính toán Daily Summaries
      for (final entry in byDate.entries) {
        final dateKey = entry.key;
        final dailyExpenses = entry.value;
        final date = dailyExpenses.first.date;

        final dailySummary =
            SummaryService.calculateDailySummary(dailyExpenses, date);
        await upsertDailySummary(dailySummary);
      }
      log('✅ Updated daily summaries for ${byDate.length} days');

      log('🎉 Successfully recalculated all summaries!');
    } catch (e) {
      log('❌ Error in recalculateAllSummaries: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSummariesForExpense(
    Expense expense, {
    Expense? oldExpense,
    bool isDelete = false,
  }) async {
    try {
      log('🔄 Updating summaries for expense: ${expense.expenseId}');

      // Các ngày cần update (có thể khác nhau nếu update thay đổi ngày)
      final datesToUpdate = <DateTime>{expense.date};
      if (oldExpense != null) {
        datesToUpdate.add(oldExpense.date);
      }

      for (final date in datesToUpdate) {
        await _updateSummariesForDate(date);
      }

      log('✅ Updated summaries successfully');
    } catch (e) {
      log('❌ Error updating summaries: $e');
      rethrow;
    }
  }

  /// Helper method để update summaries cho một ngày cụ thể
  Future<void> _updateSummariesForDate(DateTime date) async {
    // 1. Lấy tất cả expenses của ngày đó
    final allExpenses = await getExpenses();
    final dailyExpenses = SummaryService.filterByDate(allExpenses, date);

    // 2. Update Daily Summary
    if (dailyExpenses.isNotEmpty) {
      final dailySummary =
          SummaryService.calculateDailySummary(dailyExpenses, date);
      await upsertDailySummary(dailySummary);
    }

    // 3. Update Monthly Summary
    final monthlyExpenses =
        SummaryService.filterByMonth(allExpenses, date.year, date.month);
    if (monthlyExpenses.isNotEmpty) {
      final monthlySummary = SummaryService.calculateMonthlySummary(
          monthlyExpenses, date.year, date.month);
      await upsertMonthlySummary(monthlySummary);

      // Update Category Summaries for month
      final monthlyCategorySummaries =
          SummaryService.calculateAllCategorySummariesForMonth(
              monthlyExpenses, date.year, date.month);
      for (final catSummary in monthlyCategorySummaries) {
        await upsertCategorySummary(catSummary);
      }
    }

    // 4. Update Yearly Summary
    final yearlyExpenses = SummaryService.filterByYear(allExpenses, date.year);
    if (yearlyExpenses.isNotEmpty) {
      final yearlySummary =
          SummaryService.calculateYearlySummary(yearlyExpenses, date.year);
      await upsertYearlySummary(yearlySummary);

      // Update Category Summaries for year
      final yearlyCategorySummaries =
          SummaryService.calculateAllCategorySummariesForYear(
              yearlyExpenses, date.year);
      for (final catSummary in yearlyCategorySummaries) {
        await upsertCategorySummary(catSummary);
      }
    }

    // 5. Update Overall Summary
    final overallSummary = SummaryService.calculateOverallSummary(allExpenses);
    await updateOverallSummary(overallSummary);
  }
}
