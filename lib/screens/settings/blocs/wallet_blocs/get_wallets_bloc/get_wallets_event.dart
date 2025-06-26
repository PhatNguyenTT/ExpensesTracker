part of 'get_wallets_bloc.dart';

sealed class GetWalletsEvent extends Equatable {
  const GetWalletsEvent();

  @override
  List<Object> get props => [];
}

class GetWallets extends GetWalletsEvent {}
