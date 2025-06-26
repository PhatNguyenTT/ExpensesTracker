import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconInfo {
  final IconData icon;
  final String name;

  IconInfo({required this.icon, required this.name});
}

final List<IconInfo> categoryIcons = [
  IconInfo(icon: Icons.fastfood, name: 'food'),
  IconInfo(icon: Icons.shopping_bag, name: 'shopping'),
  IconInfo(icon: Icons.local_gas_station, name: 'fuel'),
  IconInfo(icon: Icons.movie, name: 'entertainment'),
  IconInfo(icon: Icons.local_hospital, name: 'health'),
  IconInfo(icon: Icons.home, name: 'home'),
  IconInfo(icon: Icons.school, name: 'education'),
  IconInfo(icon: Icons.phone_android, name: 'phone'),
  IconInfo(icon: Icons.wifi, name: 'internet'),
  IconInfo(icon: Icons.work, name: 'salary'),
  IconInfo(icon: Icons.card_giftcard, name: 'bonus'),
  IconInfo(icon: Icons.trending_up, name: 'investment'),
  IconInfo(icon: Icons.pets, name: 'pet'),
  IconInfo(icon: Icons.devices, name: 'tech'),
  IconInfo(icon: Icons.airplane_ticket, name: 'travel'),
  IconInfo(icon: Icons.receipt_long_sharp, name: 'bills'),
  IconInfo(icon: Icons.subscriptions, name: 'subscription'),
  IconInfo(icon: Icons.sports_esports, name: 'games'),
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
