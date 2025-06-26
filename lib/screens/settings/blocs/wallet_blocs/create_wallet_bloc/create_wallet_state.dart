part of 'create_wallet_bloc.dart';

sealed class CreateWalletState extends Equatable {
  const CreateWalletState();

  @override
  List<Object> get props => [];
}

final class CreateWalletInitial extends CreateWalletState {}

final class CreateWalletLoading extends CreateWalletState {}

final class CreateWalletFailure extends CreateWalletState {}

final class CreateWalletSuccess extends CreateWalletState {
  final Wallet wallet;
  const CreateWalletSuccess(this.wallet);

  @override
  List<Object> get props => [wallet];
}
