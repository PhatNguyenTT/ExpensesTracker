part of initial_balance_bloc;

abstract class InitialBalanceEvent extends Equatable {
  const InitialBalanceEvent();

  @override
  List<Object> get props => [];
}

/// Event để tải số dư ban đầu từ repository
class LoadInitialBalance extends InitialBalanceEvent {}

/// Event để thiết lập/cập nhật số dư ban đầu
class SetInitialBalance extends InitialBalanceEvent {
  final int amount;
  final String? note;

  const SetInitialBalance({required this.amount, this.note});

  @override
  List<Object> get props => [amount, note ?? ''];
}
