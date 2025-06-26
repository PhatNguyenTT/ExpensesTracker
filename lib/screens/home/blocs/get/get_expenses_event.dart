part of 'get_expenses_bloc.dart';

sealed class GetExpensesEvent extends Equatable {
  const GetExpensesEvent();

  @override
  List<Object?> get props => [];
}

class GetExpenses extends GetExpensesEvent {
  final String? walletId;

  const GetExpenses({this.walletId});

  @override
  List<Object?> get props => [walletId];
}
