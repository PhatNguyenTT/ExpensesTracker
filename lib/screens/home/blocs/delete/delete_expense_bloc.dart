import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'delete_expense_event.dart';
part 'delete_expense_state.dart';

class DeleteExpenseBloc extends Bloc<DeleteExpenseEvent, DeleteExpenseState> {
  final ExpenseRepository _expenseRepository;

  DeleteExpenseBloc(this._expenseRepository) : super(DeleteExpenseInitial()) {
    on<DeleteExpenseRequested>((event, emit) async {
      emit(DeleteExpenseLoading());
      try {
        await _expenseRepository.deleteExpense(event.expenseId);
        emit(DeleteExpenseSuccess(event.expenseId));
      } catch (e) {
        emit(DeleteExpenseFailure(e.toString()));
      }
    });
  }
}
