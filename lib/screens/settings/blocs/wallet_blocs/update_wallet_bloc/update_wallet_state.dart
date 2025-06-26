part of 'update_wallet_bloc.dart';

sealed class UpdateWalletState extends Equatable {
  const UpdateWalletState();

  @override
  List<Object> get props => [];
}

final class UpdateWalletInitial extends UpdateWalletState {}

final class UpdateWalletLoading extends UpdateWalletState {}

final class UpdateWalletSuccess extends UpdateWalletState {
  final Wallet wallet;

  const UpdateWalletSuccess(this.wallet);

  @override
  List<Object> get props => [wallet];
}

final class UpdateWalletFailure extends UpdateWalletState {
  final String message;

  const UpdateWalletFailure({required this.message});

  @override
  List<Object> get props => [message];
}
