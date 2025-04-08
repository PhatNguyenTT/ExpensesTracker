import 'package:flutter/material.dart';
import 'package:expenses_tracker/screens/stats/bar_chart.dart';
import 'package:expenses_tracker/screens/stats/pie_chart_with_badge.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int selectedChart = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedChart);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChartSelected(int index) {
    setState(() {
      selectedChart = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu đồ phân tích',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            /// Biểu đồ chính với hiệu ứng slide
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedChart = index;
                    });
                  },
                  children: const [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: PieChartWithBadge(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: MyChart(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Bộ chọn biểu đồ (custom tab)
            Center(
              child: Wrap(
                spacing: 12,
                children: [
                  _buildChartChip(
                    label: 'Biểu đồ tròn',
                    selected: selectedChart == 0,
                    onTap: () => _onChartSelected(0),
                  ),
                  _buildChartChip(
                    label: 'Biểu đồ cột',
                    selected: selectedChart == 1,
                    onTap: () => _onChartSelected(1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChartChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.deepPurple : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
