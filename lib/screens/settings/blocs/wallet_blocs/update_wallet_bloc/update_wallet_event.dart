part of 'update_wallet_bloc.dart';

sealed class UpdateWalletEvent extends Equatable {
  const UpdateWalletEvent();

  @override
  List<Object> get props => [];
}

class UpdateWallet extends UpdateWalletEvent {
  final Wallet wallet;

  const UpdateWallet(this.wallet);

  @override
  List<Object> get props => [wallet];
}
