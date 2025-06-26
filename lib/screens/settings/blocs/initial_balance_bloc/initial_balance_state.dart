part of initial_balance_bloc;

abstract class InitialBalanceState extends Equatable {
  const InitialBalanceState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu, chưa có hành động gì
class InitialBalanceInitial extends InitialBalanceState {}

/// Trạng thái đang tải hoặc đang lưu dữ liệu
class InitialBalanceLoading extends InitialBalanceState {}

/// Trạng thái tải thành công số dư ban đầu
class InitialBalanceLoaded extends InitialBalanceState {
  final InitialBalance? initialBalance;

  const InitialBalanceLoaded(this.initialBalance);

  @override
  List<Object?> get props => [initialBalance];
}

/// Trạng thái thiết lập/cập nhật thành công
class InitialBalanceSetSuccess extends InitialBalanceState {
  final int newBalance;

  const InitialBalanceSetSuccess(this.newBalance);

  @override
  List<Object> get props => [newBalance];
}

/// Trạng thái có lỗi xảy ra
class InitialBalanceFailure extends InitialBalanceState {
  final String error;

  const InitialBalanceFailure(this.error);

  @override
  List<Object> get props => [error];
}
