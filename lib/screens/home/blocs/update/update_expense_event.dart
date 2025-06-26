part of 'update_expense_bloc.dart';

abstract class UpdateExpenseEvent extends Equatable {
  const UpdateExpenseEvent();

  @override
  List<Object?> get props => [];
}

class UpdateExpenseRequested extends UpdateExpenseEvent {
  final Expense expense;

  const UpdateExpenseRequested(this.expense);

  @override
  List<Object?> get props => [expense];
}
