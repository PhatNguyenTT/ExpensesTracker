import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

part 'update_wallet_event.dart';
part 'update_wallet_state.dart';

class UpdateWalletBloc extends Bloc<UpdateWalletEvent, UpdateWalletState> {
  final ExpenseRepository expenseRepository;

  UpdateWalletBloc(this.expenseRepository) : super(UpdateWalletInitial()) {
    on<UpdateWallet>((event, emit) async {
      emit(UpdateWalletLoading());
      try {
        await expenseRepository.updateWallet(event.wallet);
        emit(UpdateWalletSuccess());
      } catch (e) {
        emit(UpdateWalletFailure(message: e.toString()));
      }
    });
  }
}
