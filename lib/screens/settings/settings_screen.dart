import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:expenses_tracker/screens/settings/category_management_screen.dart';
import 'package:expenses_tracker/screens/settings/views/initial_balance_screen.dart';
import 'package:expenses_tracker/screens/home/views/find_expense_screen.dart';

class SettingsScreen extends StatelessWidget {
  final List<Expense> expenses;
  const SettingsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Category Management
              _buildSettingsItem(
                context,
                icon: Icons.category,
                title: 'Quản lý danh mục',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryManagementScreen(),
                    ),
                  );
                },
              ),

              // Wallet Management
              _buildSettingsItem(
                context,
                icon: Icons.account_balance_wallet,
                title: 'Quản lý ví tiền',
                onTap: () {
                  _showComingSoon(context);
                },
              ),

              // Initial Balance (Mới)
              _buildSettingsItem(
                context,
                icon: Icons.attach_money,
                title: 'Thiết lập số dư ban đầu',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InitialBalanceScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.receipt_long,
                title: 'Chi phí cố định và thu nhập định kì',
                onTap: () {
                  // TODO: Fixed expenses and recurring income
                  _showComingSoon(context);
                },
              ),

              const SizedBox(height: 30),

              // Theme Section
              _buildSettingsItem(
                context,
                icon: Icons.palette,
                title: 'Thay đổi màu chủ đề',
                onTap: () {
                  // TODO: Theme settings
                  _showComingSoon(context);
                },
              ),

              const SizedBox(height: 30),

              // Reports Section
              _buildSettingsItem(
                context,
                icon: Icons.bar_chart,
                title: 'Báo cáo trong năm',
                onTap: () {
                  // TODO: Yearly reports
                  _showComingSoon(context);
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.history,
                title: 'Báo cáo danh mục trong năm',
                onTap: () {
                  // TODO: Category yearly reports
                  _showComingSoon(context);
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.analytics,
                title: 'Báo cáo toàn kì',
                onTap: () {
                  // TODO: All-time reports
                  _showComingSoon(context);
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.timeline,
                title: 'Báo cáo danh mục toàn kì',
                onTap: () {
                  // TODO: Category all-time reports
                  _showComingSoon(context);
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.trending_up,
                title: 'Báo cáo thay đổi số dư',
                onTap: () {
                  // TODO: Balance change reports
                  _showComingSoon(context);
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.search,
                title: 'Tìm kiếm giao dịch',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FindExpenseScreen(allExpenses: expenses),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Sắp ra mắt',
          style: TextStyle(color: Colors.black87),
        ),
        content: const Text(
          'Tính năng này đang được phát triển và sẽ có sẵn trong phiên bản tiếp theo.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
