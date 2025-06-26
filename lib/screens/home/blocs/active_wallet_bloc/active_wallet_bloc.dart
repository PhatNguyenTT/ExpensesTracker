import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

part 'active_wallet_event.dart';
part 'active_wallet_state.dart';

class ActiveWalletBloc extends Bloc<ActiveWalletEvent, ActiveWalletState> {
  final ExpenseRepository _expenseRepository;

  ActiveWalletBloc(this._expenseRepository) : super(ActiveWalletInitial()) {
    on<LoadActiveWallet>((event, emit) async {
      try {
        final wallets = await _expenseRepository.getWallets();
        if (wallets.isNotEmpty) {
          // By default, the first wallet is active.
          // Later, we can persist the last selected wallet's ID.
          emit(ActiveWalletLoaded(
              activeWallet: wallets.first, allWallets: wallets));
        } else {
          emit(ActiveWalletsEmpty());
        }
      } catch (e) {
        emit(ActiveWalletError());
      }
    });

    on<SetActiveWallet>((event, emit) async {
      try {
        final wallets = await _expenseRepository.getWallets();
        emit(ActiveWalletLoaded(
            activeWallet: event.newActiveWallet as Wallet,
            allWallets: wallets));
      } catch (e) {
        emit(ActiveWalletError());
      }
    });
  }
}
