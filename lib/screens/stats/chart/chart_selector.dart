import 'package:flutter/material.dart';

class ChartSelector extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const ChartSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final titles = ['Biểu đồ tròn', 'Biểu đồ cột'];

    return Center(
      child: Wrap(
        spacing: 12,
        children: List.generate(titles.length, (i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                titles[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
