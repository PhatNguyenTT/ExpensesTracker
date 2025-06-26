import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

part 'get_wallets_event.dart';
part 'get_wallets_state.dart';

class GetWalletsBloc extends Bloc<GetWalletsEvent, GetWalletsState> {
  final ExpenseRepository expenseRepository;

  GetWalletsBloc(this.expenseRepository) : super(GetWalletsInitial()) {
    on<GetWallets>((event, emit) async {
      emit(GetWalletsLoading());
      try {
        List<Wallet> wallets = await expenseRepository.getWallets();
        emit(GetWalletsSuccess(wallets));
      } catch (e) {
        emit(GetWalletsFailure());
      }
    });
  }
}
