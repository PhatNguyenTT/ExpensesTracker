import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'delete_wallet_event.dart';
part 'delete_wallet_state.dart';

class DeleteWalletBloc extends Bloc<DeleteWalletEvent, DeleteWalletState> {
  final ExpenseRepository expenseRepository;

  DeleteWalletBloc(this.expenseRepository) : super(DeleteWalletInitial()) {
    on<DeleteWallet>((event, emit) async {
      emit(DeleteWalletLoading());
      try {
        await expenseRepository.deleteWallet(event.walletId);
        emit(DeleteWalletSuccess());
      } catch (e) {
        emit(DeleteWalletFailure(message: e.toString()));
      }
    });
  }
}
