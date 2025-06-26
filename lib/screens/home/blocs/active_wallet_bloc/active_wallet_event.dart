part of 'active_wallet_bloc.dart';

sealed class ActiveWalletEvent extends Equatable {
  const ActiveWalletEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the BLoC, load wallets, and set the first one as active.
class LoadActiveWallet extends ActiveWalletEvent {}

/// Event triggered when the user selects a new wallet.
class SetActiveWallet extends ActiveWalletEvent {
  final Wallet newActiveWallet;

  const SetActiveWallet(this.newActiveWallet);

  @override
  List<Object> get props => [newActiveWallet];
}
