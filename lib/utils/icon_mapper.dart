import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconMapper {
  static final Map<String, IconData> _iconMap = {
    // Category Icons
    'food': Icons.fastfood,
    'shopping': Icons.shopping_bag,
    'fuel': Icons.local_gas_station,
    'entertainment': Icons.movie,
    'health': Icons.local_hospital,
    'home': Icons.home,
    'education': Icons.school,
    'phone': Icons.phone_android,
    'internet': Icons.wifi,
    'salary': Icons.work,
    'bonus': Icons.card_giftcard,
    'investment': Icons.trending_up,
    'pet': Icons.pets,
    'tech': Icons.devices,
    'travel': Icons.airplane_ticket,
    'bills': Icons.receipt_long_sharp,
    'subscription': Icons.subscriptions,
    'games': Icons.sports_esports,

    // Wallet Icons
    'wallet': Icons.wallet_outlined,
    'credit_card': Icons.credit_card,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'savings': Icons.savings_outlined,
    'account_balance': Icons.account_balance,
    'monetization_on': Icons.monetization_on_outlined,
    'business_center': Icons.business_center_outlined,
    'shopping_cart': Icons.shopping_cart_outlined,
    'giftcard': Icons.card_giftcard,
    //'phone_android' is already defined above, so I'll use a different one
    'payments': Icons.payments_outlined,
    'attach_money': Icons.attach_money,
    'euro': Icons.euro,
    'travel_explore': Icons.travel_explore,
    'local_mall': Icons.local_mall_outlined,
  };

  static IconData? getIcon(String name) {
    return _iconMap[name.toLowerCase()];
  }

  static String? getName(IconData icon) {
    for (var entry in _iconMap.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return null;
  }
}
