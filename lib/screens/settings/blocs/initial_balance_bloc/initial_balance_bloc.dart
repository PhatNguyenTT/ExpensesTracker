library initial_balance_bloc;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'initial_balance_event.dart';
part 'initial_balance_state.dart';

class InitialBalanceBloc
    extends Bloc<InitialBalanceEvent, InitialBalanceState> {
  final ExpenseRepository _expenseRepository;

  InitialBalanceBloc({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(InitialBalanceInitial()) {
    on<LoadInitialBalance>(_onLoadInitialBalance);
    on<SetInitialBalance>(_onSetInitialBalance);
  }

  /// Xử lý sự kiện tải số dư ban đầu
  Future<void> _onLoadInitialBalance(
    LoadInitialBalance event,
    Emitter<InitialBalanceState> emit,
  ) async {
    emit(InitialBalanceLoading());
    try {
      final initialBalance = await _expenseRepository.getInitialBalance();
      emit(InitialBalanceLoaded(initialBalance));
    } catch (e) {
      emit(InitialBalanceFailure(e.toString()));
    }
  }

  /// Xử lý sự kiện thiết lập/cập nhật số dư ban đầu
  Future<void> _onSetInitialBalance(
    SetInitialBalance event,
    Emitter<InitialBalanceState> emit,
  ) async {
    emit(InitialBalanceLoading());
    try {
      // Tạo một đối tượng InitialBalance mới
      final newBalance = InitialBalance.create(
        amount: event.amount,
        note: event.note,
      );

      // Gọi repository để lưu
      await _expenseRepository.setInitialBalance(newBalance);

      // Recalculate summaries để cập nhật số dư tổng
      await _expenseRepository.recalculateAllSummaries();

      emit(InitialBalanceSetSuccess(newBalance.amount));
    } catch (e) {
      emit(InitialBalanceFailure(e.toString()));
    }
  }
}
