import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/entities/wallet_entity.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'summary_service.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection =
      FirebaseFirestore.instance.collection('categories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');
  final walletCollection = FirebaseFirestore.instance.collection('wallets');

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

  // ========== WALLET OPERATIONS ==========
  @override
  Future<void> createWallet(Wallet wallet) async {
    try {
      await walletCollection
          .doc(wallet.walletId)
          .set(wallet.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Wallet>> getWallets() async {
    try {
      return await walletCollection.get().then((snapshot) => snapshot.docs
          .map((doc) => Wallet.fromEntity(
              WalletEntity.fromJson(doc.data() as Map<String, dynamic>)))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<Wallet?> getWallet(String walletId) async {
    try {
      final doc = await walletCollection.doc(walletId).get();
      if (doc.exists) {
        return Wallet.fromEntity(
            WalletEntity.fromJson(doc.data()! as Map<String, dynamic>));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    try {
      await walletCollection
          .doc(wallet.walletId)
          .update(wallet.toEntity().toJson());
    } catch (e) {
      log('Error updating wallet: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Delete all expenses in the wallet
      final expensesSnapshot =
          await expenseCollection.where('walletId', isEqualTo: walletId).get();
      for (final doc in expensesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 2. Delete all summaries for the wallet
      final summaryCollections = [
        dailySummaryCollection,
        monthlySummaryCollection,
        yearlySummaryCollection,
        categorySummaryCollection
      ];
      for (final collection in summaryCollections) {
        final summarySnapshot =
            await collection.where('walletId', isEqualTo: walletId).get();
        for (final doc in summarySnapshot.docs) {
          batch.delete(doc.reference);
        }
      }
      batch.delete(overallSummaryCollection.doc(walletId));

      // 3. Delete the wallet itself
      batch.delete(walletCollection.doc(walletId));

      await batch.commit();
    } catch (e) {
      log('Error deleting wallet: $e');
      rethrow;
    }
  }

  // ========== CATEGORY OPERATIONS ==========
  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
      return await categoryCollection.get().then((value) => value.docs
          .map((e) => Category.fromEntity(
              CategoryEntity.fromJson(e.data() as Map<String, dynamic>)))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .update(category.toEntity().toJson());
    } catch (e) {
      log('Error updating category: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isCategoryInUse(String categoryId) async {
    try {
      final snapshot = await expenseCollection
          .where('category.categoryId', isEqualTo: categoryId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId,
      {String? walletId}) async {
    try {
      Query query =
          expenseCollection.where('category.categoryId', isEqualTo: categoryId);
      if (walletId != null) {
        query = query.where('walletId', isEqualTo: walletId);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => Expense.fromEntity(
              ExpenseEntity.fromJson(doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      log('🗑️ Attempting to delete category: $categoryId');

      final isInUse = await isCategoryInUse(categoryId);
      if (isInUse) {
        log('❌ Cannot delete category: still in use by expenses');
        throw Exception(
            'Category đang được sử dụng bởi các giao dịch. Vui lòng xóa các giao dịch liên quan trước.');
      }

      final batch = FirebaseFirestore.instance.batch();
      final categorySummariesSnapshot = await categorySummaryCollection
          .where('categoryId', isEqualTo: categoryId)
          .get();

      for (final doc in categorySummariesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(categoryCollection.doc(categoryId));

      await batch.commit();

      log('✅ Successfully deleted category and related summaries');
    } catch (e) {
      log('❌ Error deleting category: $e');
      rethrow;
    }
  }

  // ========== EXPENSE OPERATIONS ==========
  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toJson());

      await updateSummariesForExpense(expense);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpenses({String? walletId}) async {
    try {
      Query query = expenseCollection;
      if (walletId != null) {
        query = query.where('walletId', isEqualTo: walletId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((e) => Expense.fromEntity(
              ExpenseEntity.fromJson(e.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      final oldExpenseDoc =
          await expenseCollection.doc(expense.expenseId).get();
      Expense? oldExpense;
      if (oldExpenseDoc.exists) {
        oldExpense = Expense.fromEntity(ExpenseEntity.fromJson(
            oldExpenseDoc.data()! as Map<String, dynamic>));
      }

      await expenseCollection
          .doc(expense.expenseId)
          .update(expense.toEntity().toJson());

      await updateSummariesForExpense(expense, oldExpense: oldExpense);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      final expenseDoc = await expenseCollection.doc(expenseId).get();
      if (expenseDoc.exists) {
        final expense = Expense.fromEntity(
            ExpenseEntity.fromJson(expenseDoc.data()! as Map<String, dynamic>));

        await expenseCollection.doc(expenseId).delete();

        await updateSummariesForExpense(expense, isDelete: true);
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== OVERALL SUMMARY ==========
  @override
  Future<OverallSummary> getOverallSummary(String walletId) async {
    try {
      final doc = await overallSummaryCollection.doc(walletId).get();
      if (doc.exists) {
        return OverallSummary.fromEntity(
            OverallSummaryEntity.fromJson(doc.data()! as Map<String, dynamic>));
      } else {
        final expenses = await getExpenses(walletId: walletId);
        final summary =
            SummaryService.calculateOverallSummary(expenses, walletId);
        await upsertOverallSummary(summary);
        return summary;
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> upsertOverallSummary(OverallSummary summary) async {
    try {
      await overallSummaryCollection
          .doc(summary.summaryId)
          .set(summary.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== MONTHLY SUMMARY ==========
  @override
  Future<MonthlySummary?> getMonthlySummary(
      String walletId, int year, int month) async {
    try {
      final summaryId = MonthlySummary.generateId(walletId, year, month);
      final doc = await monthlySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return MonthlySummary.fromEntity(
            MonthlySummaryEntity.fromJson(doc.data()! as Map<String, dynamic>));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<MonthlySummary>> getMonthlyRangeSummary(
      String walletId, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await monthlySummaryCollection
          .where('walletId', isEqualTo: walletId)
          .where('year', isGreaterThanOrEqualTo: startDate.year)
          .where('year', isLessThanOrEqualTo: endDate.year)
          .get();

      // Further filtering by month in Dart
      return snapshot.docs
          .map((doc) => MonthlySummary.fromEntity(MonthlySummaryEntity.fromJson(
              doc.data() as Map<String, dynamic>)))
          .where((summary) {
        final summaryDate = DateTime(summary.year, summary.month);
        final start = DateTime(startDate.year, startDate.month);
        final end = DateTime(endDate.year, endDate.month);
        return summaryDate.isAfter(start) ||
            summaryDate.isAtSameMomentAs(start) && summaryDate.isBefore(end) ||
            summaryDate.isAtSameMomentAs(end);
      }).toList();
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
          .set(summary.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== YEARLY SUMMARY ==========
  @override
  Future<YearlySummary?> getYearlySummary(String walletId, int year) async {
    try {
      final summaryId = YearlySummary.generateId(walletId, year);
      final doc = await yearlySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return YearlySummary.fromEntity(
            YearlySummaryEntity.fromJson(doc.data()! as Map<String, dynamic>));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<YearlySummary>> getYearlyRangeSummary(
      String walletId, int startYear, int endYear) async {
    try {
      final snapshot = await yearlySummaryCollection
          .where('walletId', isEqualTo: walletId)
          .where('year', isGreaterThanOrEqualTo: startYear)
          .where('year', isLessThanOrEqualTo: endYear)
          .get();

      return snapshot.docs
          .map((doc) => YearlySummary.fromEntity(
              YearlySummaryEntity.fromJson(doc.data() as Map<String, dynamic>)))
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
          .set(summary.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== DAILY SUMMARY ==========
  @override
  Future<DailySummary?> getDailySummary(String walletId, DateTime date) async {
    try {
      final summaryId = DailySummary.generateId(walletId, date);
      final doc = await dailySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return DailySummary.fromEntity(
            DailySummaryEntity.fromJson(doc.data()! as Map<String, dynamic>));
      }
      return null;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<DailySummary>> getDailyRangeSummary(
      String walletId, DateTime startDate, DateTime endDate) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      final snapshot = await dailySummaryCollection
          .where('walletId', isEqualTo: walletId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs
          .map((doc) => DailySummary.fromEntity(
              DailySummaryEntity.fromJson(doc.data() as Map<String, dynamic>)))
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
          .set(summary.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== CATEGORY SUMMARY ==========
  @override
  Future<List<CategorySummary>> getCategorySummaryByMonth(
      String walletId, int year, int month) async {
    try {
      final snapshot = await categorySummaryCollection
          .where('walletId', isEqualTo: walletId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .get();

      return snapshot.docs
          .map((doc) => CategorySummary.fromEntity(
              CategorySummaryEntity.fromJson(
                  doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<CategorySummary>> getCategorySummaryByYear(
      String walletId, int year) async {
    try {
      final snapshot = await categorySummaryCollection
          .where('walletId', isEqualTo: walletId)
          .where('year', isEqualTo: year)
          .where('month', isNull: true)
          .get();

      return snapshot.docs
          .map((doc) => CategorySummary.fromEntity(
              CategorySummaryEntity.fromJson(
                  doc.data() as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<CategorySummary?> getCategorySummary(
      String walletId, String categoryId, int year, int? month) async {
    try {
      final summaryId = month != null
          ? CategorySummary.generateMonthlyId(walletId, categoryId, year, month)
          : CategorySummary.generateYearlyId(walletId, categoryId, year);

      final doc = await categorySummaryCollection.doc(summaryId).get();

      if (doc.exists) {
        return CategorySummary.fromEntity(CategorySummaryEntity.fromJson(
            doc.data()! as Map<String, dynamic>));
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
          .set(summary.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // ========== BALANCE CALCULATIONS ==========
  @override
  Future<int> getRealBalanceAtDate(String walletId, DateTime date) async {
    try {
      final [wallet, expenses] = await Future.wait([
        getWallet(walletId),
        getExpenses(walletId: walletId),
      ]);

      return SummaryService.calculateRealBalanceAtDate(
          expenses as List<Expense>, date, wallet as Wallet?);
    } catch (e) {
      log('Error getting real balance at date: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCurrentRealBalance(String walletId) async {
    try {
      return await getRealBalanceAtDate(walletId, DateTime.now());
    } catch (e) {
      log('Error getting current real balance: $e');
      rethrow;
    }
  }

  // ========== BATCH OPERATIONS ==========
  @override
  Future<void> recalculateSummariesForWallet(String walletId) async {
    try {
      log('🔄 Starting recalculation of all summaries for wallet $walletId...');

      final expenses = await getExpenses(walletId: walletId);
      log('📊 Loaded ${expenses.length} expenses for wallet $walletId');

      if (expenses.isEmpty) {
        log('⚠️ No expenses found, skipping summary calculation for wallet $walletId');
        return;
      }

      final overallSummary =
          SummaryService.calculateOverallSummary(expenses, walletId);
      await upsertOverallSummary(overallSummary);
      log('✅ Updated overall summary for wallet $walletId');

      final Map<int, List<Expense>> byYear = {};
      final Map<String, List<Expense>> byMonth = {};
      final Map<String, List<Expense>> byDate = {};

      for (final expense in expenses) {
        if (!byYear.containsKey(expense.date.year))
          byYear[expense.date.year] = [];
        byYear[expense.date.year]!.add(expense);

        final monthKey = '${expense.date.year}-${expense.date.month}';
        if (!byMonth.containsKey(monthKey)) byMonth[monthKey] = [];
        byMonth[monthKey]!.add(expense);

        final dateKey = DailySummary.generateId(walletId, expense.date);
        if (!byDate.containsKey(dateKey)) byDate[dateKey] = [];
        byDate[dateKey]!.add(expense);
      }

      for (final entry in byYear.entries) {
        final year = entry.key;
        final yearExpenses = entry.value;

        final yearlySummary =
            SummaryService.calculateYearlySummary(yearExpenses, walletId, year);
        await upsertYearlySummary(yearlySummary);

        final categorySummaries =
            SummaryService.calculateAllCategorySummariesForYear(
                yearExpenses, walletId, year);
        for (final catSummary in categorySummaries) {
          await upsertCategorySummary(catSummary);
        }
      }
      log('✅ Updated yearly summaries for wallet $walletId');

      for (final entry in byMonth.entries) {
        final parts = entry.key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final monthExpenses = entry.value;

        final monthlySummary = SummaryService.calculateMonthlySummary(
            monthExpenses, walletId, year, month);
        await upsertMonthlySummary(monthlySummary);

        final categorySummaries =
            SummaryService.calculateAllCategorySummariesForMonth(
                monthExpenses, walletId, year, month);
        for (final catSummary in categorySummaries) {
          await upsertCategorySummary(catSummary);
        }
      }
      log('✅ Updated monthly summaries for wallet $walletId');

      for (final entry in byDate.entries) {
        final dailyExpenses = entry.value;
        final date = dailyExpenses.first.date;
        final dailySummary =
            SummaryService.calculateDailySummary(dailyExpenses, walletId, date);
        await upsertDailySummary(dailySummary);
      }
      log('✅ Updated daily summaries for wallet $walletId');

      log('🎉 Successfully recalculated all summaries for wallet $walletId!');
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
      log('🔄 Updating summaries for expense: ${expense.expenseId} in wallet: ${expense.walletId}');

      final Set<DateTime> datesToUpdate = {expense.date};
      if (oldExpense != null && oldExpense.date != expense.date) {
        datesToUpdate.add(oldExpense.date);
      }

      for (final date in datesToUpdate) {
        await _updateSummariesForDate(expense.walletId, date);
      }

      log('✅ Updated summaries successfully for wallet ${expense.walletId}');
    } catch (e) {
      log('❌ Error updating summaries: $e');
      rethrow;
    }
  }

  /// Helper method to update summaries for a specific date in a specific wallet
  Future<void> _updateSummariesForDate(String walletId, DateTime date) async {
    final allExpensesInWallet = await getExpenses(walletId: walletId);

    // 1. Update Daily Summary
    final dailyExpenses =
        SummaryService.filterByDate(allExpensesInWallet, date);
    final dailySummary =
        SummaryService.calculateDailySummary(dailyExpenses, walletId, date);
    await upsertDailySummary(dailySummary);

    // 2. Update Monthly Summary
    final monthlyExpenses = SummaryService.filterByMonth(
        allExpensesInWallet, date.year, date.month);
    final monthlySummary = SummaryService.calculateMonthlySummary(
        monthlyExpenses, walletId, date.year, date.month);
    await upsertMonthlySummary(monthlySummary);

    final monthlyCategorySummaries =
        SummaryService.calculateAllCategorySummariesForMonth(
            monthlyExpenses, walletId, date.year, date.month);
    for (final catSummary in monthlyCategorySummaries) {
      await upsertCategorySummary(catSummary);
    }

    // 3. Update Yearly Summary
    final yearlyExpenses =
        SummaryService.filterByYear(allExpensesInWallet, date.year);
    final yearlySummary = SummaryService.calculateYearlySummary(
        yearlyExpenses, walletId, date.year);
    await upsertYearlySummary(yearlySummary);

    final yearlyCategorySummaries =
        SummaryService.calculateAllCategorySummariesForYear(
            yearlyExpenses, walletId, date.year);
    for (final catSummary in yearlyCategorySummaries) {
      await upsertCategorySummary(catSummary);
    }

    // 4. Update Overall Summary
    final overallSummary =
        SummaryService.calculateOverallSummary(allExpensesInWallet, walletId);
    await upsertOverallSummary(overallSummary);
  }
}
