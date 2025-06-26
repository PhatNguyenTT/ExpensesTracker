part of 'get_wallets_bloc.dart';

sealed class GetWalletsState extends Equatable {
  const GetWalletsState();

  @override
  List<Object> get props => [];
}

final class GetWalletsInitial extends GetWalletsState {}

final class GetWalletsLoading extends GetWalletsState {}

final class GetWalletsFailure extends GetWalletsState {}

final class GetWalletsSuccess extends GetWalletsState {
  final List<Wallet> wallets;

  const GetWalletsSuccess(this.wallets);

  @override
  List<Object> get props => [wallets];
}
