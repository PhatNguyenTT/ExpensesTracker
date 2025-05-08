import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIcon {
  final IconData icon;
  final String name;

  CategoryIcon(this.icon, this.name);
}

final List<CategoryIcon> categoryIcons = [
  CategoryIcon(Icons.fastfood, 'Fast Food'),
  CategoryIcon(FontAwesomeIcons.burger, 'Burger'),
  CategoryIcon(FontAwesomeIcons.utensils, 'Restaurant'),
  CategoryIcon(FontAwesomeIcons.carrot, 'Vegetables'),
  CategoryIcon(FontAwesomeIcons.fish, 'Seafood'),
  CategoryIcon(FontAwesomeIcons.appleWhole, 'Fruits'),
  CategoryIcon(FontAwesomeIcons.beerMugEmpty, 'Beverages'),
  CategoryIcon(FontAwesomeIcons.shoppingCart, 'Groceries'),
  CategoryIcon(FontAwesomeIcons.shoppingBag, 'Clothing'),
  CategoryIcon(FontAwesomeIcons.house, 'Rent'),
  CategoryIcon(FontAwesomeIcons.plug, 'Electricity'),
  CategoryIcon(FontAwesomeIcons.shower, 'Water'),
  CategoryIcon(FontAwesomeIcons.wifi, 'Internet'),
  CategoryIcon(FontAwesomeIcons.shieldHalved, 'Insurance'),
  CategoryIcon(FontAwesomeIcons.bolt, 'Utilities'),
  CategoryIcon(FontAwesomeIcons.tv, 'TV'),
  CategoryIcon(FontAwesomeIcons.laptop, 'Laptop'),
  CategoryIcon(FontAwesomeIcons.mobile, 'Mobile'),
  CategoryIcon(FontAwesomeIcons.camera, 'Camera'),
  CategoryIcon(FontAwesomeIcons.clock, 'Watches'),
  CategoryIcon(FontAwesomeIcons.couch, 'Furniture'),
  CategoryIcon(FontAwesomeIcons.bed, 'Bedding'),
  CategoryIcon(FontAwesomeIcons.tools, 'Repair'),
  CategoryIcon(FontAwesomeIcons.car, 'Car'),
  CategoryIcon(FontAwesomeIcons.gasPump, 'Fuel'),
  CategoryIcon(FontAwesomeIcons.bus, 'Public Transport'),
  CategoryIcon(FontAwesomeIcons.plane, 'Flights'),
  CategoryIcon(FontAwesomeIcons.trainSubway, 'Subway'),
  CategoryIcon(FontAwesomeIcons.taxi, 'Taxi'),
  CategoryIcon(FontAwesomeIcons.hotel, 'Hotel'),
  CategoryIcon(FontAwesomeIcons.tree, 'Nature'),
  CategoryIcon(FontAwesomeIcons.seedling, 'Garden'),
  CategoryIcon(FontAwesomeIcons.cat, 'Pet - Cat'),
  CategoryIcon(FontAwesomeIcons.dog, 'Pet - Dog'),
  CategoryIcon(FontAwesomeIcons.paw, 'Pet Care'),
  CategoryIcon(FontAwesomeIcons.stethoscope, 'Medical'),
  CategoryIcon(FontAwesomeIcons.pills, 'Medicine'),
  CategoryIcon(FontAwesomeIcons.hospital, 'Hospital'),
  CategoryIcon(FontAwesomeIcons.heartbeat, 'Health Insurance'),
  CategoryIcon(FontAwesomeIcons.book, 'Books'),
  CategoryIcon(FontAwesomeIcons.graduationCap, 'Education'),
  CategoryIcon(FontAwesomeIcons.school, 'School Fees'),
  CategoryIcon(FontAwesomeIcons.briefcase, 'Work'),
  CategoryIcon(FontAwesomeIcons.moneyBill, 'Salary'),
  CategoryIcon(FontAwesomeIcons.piggyBank, 'Saving'),
  CategoryIcon(FontAwesomeIcons.coins, 'Investment'),
  CategoryIcon(FontAwesomeIcons.handHoldingUsd, 'Loan Payment'),
  CategoryIcon(FontAwesomeIcons.handHoldingHeart, 'Donation'),
  CategoryIcon(FontAwesomeIcons.gift, 'Gifts'),
  CategoryIcon(FontAwesomeIcons.tshirt, 'Fashion'),
  CategoryIcon(FontAwesomeIcons.brush, 'Cosmetics'),
  CategoryIcon(FontAwesomeIcons.cut, 'Salon'),
  CategoryIcon(FontAwesomeIcons.ticket, 'Movie'),
  CategoryIcon(FontAwesomeIcons.gamepad, 'Games'),
  CategoryIcon(FontAwesomeIcons.music, 'Music'),
  CategoryIcon(FontAwesomeIcons.paintBrush, 'Art'),
  CategoryIcon(FontAwesomeIcons.hiking, 'Outdoor'),
  CategoryIcon(FontAwesomeIcons.dumbbell, 'Gym'),
  CategoryIcon(FontAwesomeIcons.basketball, 'Sports'),
  CategoryIcon(FontAwesomeIcons.campground, 'Camping'),
  CategoryIcon(FontAwesomeIcons.planeDeparture, 'Vacation'),
  CategoryIcon(FontAwesomeIcons.mountain, 'Adventure'),
  CategoryIcon(FontAwesomeIcons.cross, 'Religion'),
  CategoryIcon(FontAwesomeIcons.sun, 'Solar Energy'),
  CategoryIcon(FontAwesomeIcons.moon, 'Nightlife'),
  CategoryIcon(FontAwesomeIcons.wallet, 'Wallet'),
  CategoryIcon(FontAwesomeIcons.cashRegister, 'Cash'),
  CategoryIcon(FontAwesomeIcons.chartLine, 'Stocks'),
  CategoryIcon(FontAwesomeIcons.chartPie, 'Statistics'),
  CategoryIcon(FontAwesomeIcons.exchangeAlt, 'Exchange'),
  CategoryIcon(FontAwesomeIcons.suitcase, 'Business Trip'),
  CategoryIcon(FontAwesomeIcons.fingerprint, 'Security'),
  CategoryIcon(FontAwesomeIcons.handSparkles, 'Cleaning'),
  CategoryIcon(FontAwesomeIcons.soap, 'Hygiene'),
  CategoryIcon(FontAwesomeIcons.trash, 'Waste'),
  CategoryIcon(FontAwesomeIcons.trophy, 'Achievements'),
  CategoryIcon(FontAwesomeIcons.wineGlass, 'Alcohol'),
  CategoryIcon(FontAwesomeIcons.smileBeam, 'Fun'),
  CategoryIcon(FontAwesomeIcons.userFriends, 'Social'),
  CategoryIcon(FontAwesomeIcons.calendar, 'Events'),
  CategoryIcon(FontAwesomeIcons.treeCity, 'City Fee'),
  CategoryIcon(FontAwesomeIcons.anchor, 'Boat'),
  CategoryIcon(FontAwesomeIcons.fan, 'Cooling'),
  CategoryIcon(FontAwesomeIcons.fire, 'Heating'),
  CategoryIcon(FontAwesomeIcons.lock, 'Subscriptions'),
  CategoryIcon(FontAwesomeIcons.key, 'Keys'),
  CategoryIcon(FontAwesomeIcons.mapMarkedAlt, 'Maps'),
  CategoryIcon(FontAwesomeIcons.gem, 'Luxury'),
  CategoryIcon(FontAwesomeIcons.exclamation, 'Unexpected'),
  CategoryIcon(FontAwesomeIcons.building, 'Mortgage'),
  CategoryIcon(FontAwesomeIcons.globe, 'Online Services'),
  CategoryIcon(FontAwesomeIcons.seedling, 'Eco Fee'),
  CategoryIcon(FontAwesomeIcons.snowflake, 'Winter'),
  CategoryIcon(FontAwesomeIcons.faucetDrip, 'Plumbing'),
  CategoryIcon(FontAwesomeIcons.broom, 'Housekeeping'),
  CategoryIcon(FontAwesomeIcons.chartBar, 'Finance'),
  CategoryIcon(FontAwesomeIcons.envelopeOpenText, 'Postage'),
  CategoryIcon(FontAwesomeIcons.handshake, 'Freelance'),
  CategoryIcon(FontAwesomeIcons.box, 'Delivery'),
];

class IconPickerGrid extends StatelessWidget {
  final IconData? selectedIcon;
  final Function(IconData icon) onIconSelected;
  final ScrollController? scrollController;

  const IconPickerGrid({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      shrinkWrap: true,
      itemCount: categoryIcons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final icon = categoryIcons[index];
        final isSelected = selectedIcon == icon.icon;
        return GestureDetector(
          onTap: () => onIconSelected(icon.icon),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon.icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
