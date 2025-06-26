import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconInfo {
  final IconData icon;
  final String name;

  IconInfo({required this.icon, required this.name});
}

final List<IconInfo> categoryIcons = [
  // Food & Drinks
  IconInfo(icon: FontAwesomeIcons.utensils, name: 'restaurant'),
  IconInfo(icon: FontAwesomeIcons.burger, name: 'fast_food'),
  IconInfo(icon: FontAwesomeIcons.pizzaSlice, name: 'pizza'),
  IconInfo(icon: FontAwesomeIcons.mugSaucer, name: 'coffee'),
  IconInfo(icon: FontAwesomeIcons.martiniGlass, name: 'drinks'),
  IconInfo(icon: FontAwesomeIcons.carrot, name: 'groceries'),

  // Housing & Bills
  IconInfo(icon: FontAwesomeIcons.house, name: 'rent'),
  IconInfo(icon: FontAwesomeIcons.lightbulb, name: 'electricity'),
  IconInfo(icon: FontAwesomeIcons.faucetDrip, name: 'water'),
  IconInfo(icon: FontAwesomeIcons.wifi, name: 'internet'),
  IconInfo(icon: FontAwesomeIcons.phone, name: 'phone_bill'),
  IconInfo(icon: FontAwesomeIcons.fileInvoiceDollar, name: 'other_bills'),

  // Transportation
  IconInfo(icon: FontAwesomeIcons.gasPump, name: 'fuel'),
  IconInfo(icon: FontAwesomeIcons.car, name: 'car_maintenance'),
  IconInfo(icon: FontAwesomeIcons.busSimple, name: 'public_transport'),
  IconInfo(icon: FontAwesomeIcons.taxi, name: 'taxi'),
  IconInfo(icon: FontAwesomeIcons.train, name: 'train'),
  IconInfo(icon: FontAwesomeIcons.plane, name: 'flight'),

  // Shopping
  IconInfo(icon: FontAwesomeIcons.shirt, name: 'clothing'),
  IconInfo(icon: FontAwesomeIcons.laptop, name: 'electronics'),
  IconInfo(icon: FontAwesomeIcons.couch, name: 'furniture'),
  IconInfo(icon: FontAwesomeIcons.gift, name: 'gifts'),
  IconInfo(icon: FontAwesomeIcons.bagShopping, name: 'other_shopping'),

  // Health & Wellness
  IconInfo(icon: FontAwesomeIcons.stethoscope, name: 'doctor'),
  IconInfo(icon: FontAwesomeIcons.pills, name: 'pharmacy'),
  IconInfo(icon: FontAwesomeIcons.heartPulse, name: 'health_insurance'),
  IconInfo(icon: FontAwesomeIcons.dumbbell, name: 'gym'),
  IconInfo(icon: FontAwesomeIcons.spa, name: 'spa_wellness'),

  // Entertainment
  IconInfo(icon: FontAwesomeIcons.film, name: 'movies'),
  IconInfo(icon: FontAwesomeIcons.gamepad, name: 'games'),
  IconInfo(icon: FontAwesomeIcons.music, name: 'music'),
  IconInfo(icon: FontAwesomeIcons.book, name: 'books'),
  IconInfo(icon: FontAwesomeIcons.ticket, name: 'events'),

  // Education
  IconInfo(icon: FontAwesomeIcons.graduationCap, name: 'tuition'),
  IconInfo(icon: FontAwesomeIcons.bookOpenReader, name: 'courses'),

  // Pets
  IconInfo(icon: FontAwesomeIcons.dog, name: 'dog'),
  IconInfo(icon: FontAwesomeIcons.cat, name: 'cat'),
  IconInfo(icon: FontAwesomeIcons.paw, name: 'pet_food_supplies'),

  // Income
  IconInfo(icon: FontAwesomeIcons.moneyBillWave, name: 'salary'),
  IconInfo(icon: FontAwesomeIcons.briefcase, name: 'freelance'),
  IconInfo(icon: FontAwesomeIcons.chartLine, name: 'investment_income'),
  IconInfo(icon: FontAwesomeIcons.sackDollar, name: 'bonus'),

  // Others
  IconInfo(icon: FontAwesomeIcons.moneyCheckDollar, name: 'insurance_payout'),
  IconInfo(icon: FontAwesomeIcons.handHoldingDollar, name: 'donation'),
  IconInfo(icon: FontAwesomeIcons.boxesPacking, name: 'miscellaneous'),
];

class IconPickerGrid extends StatelessWidget {
  final List<IconInfo> icons;
  final IconData? selectedIcon;
  final Function(IconData) onIconSelected;
  final ScrollController? scrollController;

  const IconPickerGrid({
    super.key,
    required this.icons,
    required this.selectedIcon,
    required this.onIconSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconInfo = icons[index];
        final isSelected = selectedIcon == iconInfo.icon;
        return GestureDetector(
          onTap: () => onIconSelected(iconInfo.icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              iconInfo.icon,
              color: isSelected ? Colors.blue : Colors.grey.shade600,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
