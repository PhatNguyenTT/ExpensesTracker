import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

part 'create_wallet_event.dart';
part 'create_wallet_state.dart';

class CreateWalletBloc extends Bloc<CreateWalletEvent, CreateWalletState> {
  final ExpenseRepository expenseRepository;

  CreateWalletBloc(this.expenseRepository) : super(CreateWalletInitial()) {
    on<CreateWallet>((event, emit) async {
      emit(CreateWalletLoading());
      try {
        await expenseRepository.createWallet(event.wallet);
        emit(CreateWalletSuccess(event.wallet));
      } catch (e) {
        emit(CreateWalletFailure());
      }
    });
  }
}
