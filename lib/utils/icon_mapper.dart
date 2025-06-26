import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconMapper {
  static final Map<String, IconData> _iconMap = {
    // Food & Drinks
    'restaurant': FontAwesomeIcons.utensils,
    'fast_food': FontAwesomeIcons.burger,
    'pizza': FontAwesomeIcons.pizzaSlice,
    'coffee': FontAwesomeIcons.mugSaucer,
    'drinks': FontAwesomeIcons.martiniGlass,
    'groceries': FontAwesomeIcons.carrot,

    // Housing & Bills
    'rent': FontAwesomeIcons.house,
    'electricity': FontAwesomeIcons.lightbulb,
    'water': FontAwesomeIcons.faucetDrip,
    'internet': FontAwesomeIcons.wifi,
    'phone_bill': FontAwesomeIcons.phone,
    'other_bills': FontAwesomeIcons.fileInvoiceDollar,

    // Transportation
    'fuel': FontAwesomeIcons.gasPump,
    'car_maintenance': FontAwesomeIcons.car,
    'public_transport': FontAwesomeIcons.busSimple,
    'taxi': FontAwesomeIcons.taxi,
    'train': FontAwesomeIcons.train,
    'flight': FontAwesomeIcons.plane,

    // Shopping
    'clothing': FontAwesomeIcons.shirt,
    'electronics': FontAwesomeIcons.laptop,
    'furniture': FontAwesomeIcons.couch,
    'gifts': FontAwesomeIcons.gift,
    'other_shopping': FontAwesomeIcons.bagShopping,

    // Health & Wellness
    'doctor': FontAwesomeIcons.stethoscope,
    'pharmacy': FontAwesomeIcons.pills,
    'health_insurance': FontAwesomeIcons.heartPulse,
    'gym': FontAwesomeIcons.dumbbell,
    'spa_wellness': FontAwesomeIcons.spa,

    // Entertainment
    'movies': FontAwesomeIcons.film,
    'games': FontAwesomeIcons.gamepad,
    'music': FontAwesomeIcons.music,
    'books': FontAwesomeIcons.book,
    'events': FontAwesomeIcons.ticket,

    // Education
    'tuition': FontAwesomeIcons.graduationCap,
    'courses': FontAwesomeIcons.bookOpenReader,

    // Pets
    'dog': FontAwesomeIcons.dog,
    'cat': FontAwesomeIcons.cat,
    'pet_food_supplies': FontAwesomeIcons.paw,

    // Income
    'salary': FontAwesomeIcons.moneyBillWave,
    'freelance': FontAwesomeIcons.briefcase,
    'investment_income': FontAwesomeIcons.chartLine,
    'bonus': FontAwesomeIcons.sackDollar,

    // Others
    'insurance_payout': FontAwesomeIcons.moneyCheckDollar,
    'donation': FontAwesomeIcons.handHoldingDollar,
    'miscellaneous': FontAwesomeIcons.boxesPacking,

    // Wallet Icons (from previous step)
    'wallet': Icons.wallet_outlined,
    'credit_card': Icons.credit_card,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'savings': Icons.savings_outlined,
    'account_balance': Icons.account_balance,
    'monetization_on': Icons.monetization_on_outlined,
    'business_center': Icons.business_center_outlined,
    'shopping_cart': Icons.shopping_cart_outlined,
    'giftcard': Icons.card_giftcard,
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
