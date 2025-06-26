import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'update_expense_event.dart';
part 'update_expense_state.dart';

class UpdateExpenseBloc extends Bloc<UpdateExpenseEvent, UpdateExpenseState> {
  final ExpenseRepository _expenseRepository;

  UpdateExpenseBloc(this._expenseRepository) : super(UpdateExpenseInitial()) {
    on<UpdateExpenseRequested>((event, emit) async {
      emit(UpdateExpenseLoading());
      try {
        await _expenseRepository.updateExpense(event.expense);
        emit(UpdateExpenseSuccess(event.expense));
      } catch (e) {
        emit(UpdateExpenseFailure(e.toString()));
      }
    });
  }
}
