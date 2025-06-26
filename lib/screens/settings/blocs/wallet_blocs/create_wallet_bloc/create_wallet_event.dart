part of 'create_wallet_bloc.dart';

sealed class CreateWalletEvent extends Equatable {
  const CreateWalletEvent();

  @override
  List<Object> get props => [];
}

class CreateWallet extends CreateWalletEvent {
  final Wallet wallet;

  const CreateWallet(this.wallet);

  @override
  List<Object> get props => [wallet];
}
