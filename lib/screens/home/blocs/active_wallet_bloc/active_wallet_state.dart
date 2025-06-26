part of 'active_wallet_bloc.dart';

sealed class ActiveWalletState extends Equatable {
  const ActiveWalletState();

  @override
  List<Object?> get props => [];
}

/// Initial state, before any wallet is loaded.
final class ActiveWalletInitial extends ActiveWalletState {}

/// State when the active wallet is successfully loaded and available.
final class ActiveWalletLoaded extends ActiveWalletState {
  final dynamic activeWallet;
  final List<dynamic> allWallets;

  const ActiveWalletLoaded(
      {required this.activeWallet, required this.allWallets});

  @override
  List<Object> get props => [activeWallet, allWallets];
}

/// State when there are no wallets created yet.
final class ActiveWalletsEmpty extends ActiveWalletState {}

/// State when an error occurs.
final class ActiveWalletError extends ActiveWalletState {}
