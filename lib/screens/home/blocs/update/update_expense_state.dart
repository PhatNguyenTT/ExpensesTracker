part of 'update_expense_bloc.dart';

abstract class UpdateExpenseState extends Equatable {
  const UpdateExpenseState();

  @override
  List<Object?> get props => [];
}

class UpdateExpenseInitial extends UpdateExpenseState {}

class UpdateExpenseLoading extends UpdateExpenseState {}

class UpdateExpenseSuccess extends UpdateExpenseState {
  final Expense expense;

  const UpdateExpenseSuccess(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseFailure extends UpdateExpenseState {
  final String error;

  const UpdateExpenseFailure(this.error);

  @override
  List<Object?> get props => [error];
}
