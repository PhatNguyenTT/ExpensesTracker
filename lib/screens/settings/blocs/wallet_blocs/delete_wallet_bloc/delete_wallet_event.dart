part of 'delete_wallet_bloc.dart';

sealed class DeleteWalletEvent extends Equatable {
  const DeleteWalletEvent();

  @override
  List<Object> get props => [];
}

class DeleteWallet extends DeleteWalletEvent {
  final String walletId;

  const DeleteWallet(this.walletId);

  @override
  List<Object> get props => [walletId];
}
