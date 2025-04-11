part of 'delete_expense_bloc.dart';

abstract class DeleteExpenseEvent extends Equatable {
  const DeleteExpenseEvent();

  @override
  List<Object?> get props => [];
}

class DeleteExpenseRequested extends DeleteExpenseEvent {
  final String expenseId;

  const DeleteExpenseRequested(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}
