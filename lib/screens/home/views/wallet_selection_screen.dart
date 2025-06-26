import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/active_wallet_bloc/active_wallet_bloc.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletSelectionScreen extends StatelessWidget {
  const WalletSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chọn ví'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<ActiveWalletBloc, ActiveWalletState>(
        builder: (context, state) {
          if (state is ActiveWalletLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.allWallets.length,
              itemBuilder: (context, index) {
                final wallet = state.allWallets[index];
                final bool isActive =
                    wallet.walletId == state.activeWallet.walletId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      if (!isActive) {
                        context
                            .read<ActiveWalletBloc>()
                            .add(SetActiveWallet(wallet));
                      }
                      Navigator.of(context).pop();
                    },
                    leading: Icon(
                      IconMapper.getIcon(wallet.icon),
                      color: wallet.color,
                    ),
                    title: Text(wallet.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: isActive
                        ? Icon(Icons.check_circle,
                            color: Theme.of(context).primaryColor)
                        : null,
                  ),
                );
              },
            );
          }
          if (state is ActiveWalletsEmpty) {
            return const Center(child: Text("Bạn chưa có ví nào."));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
