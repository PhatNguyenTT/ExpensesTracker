import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/settings/blocs/update_category_bloc/update_category_bloc.dart';
import 'package:expenses_tracker/screens/settings/blocs/delete_category_bloc/delete_category_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/categoryCreation.dart';
import 'package:expenses_tracker/screens/settings/views/category_edit_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories()),
        ),
        BlocProvider(
          create: (context) => CreateCategoryBloc(FirebaseExpenseRepo()),
        ),
        BlocProvider(
          create: (context) => UpdateCategoryBloc(FirebaseExpenseRepo()),
        ),
        BlocProvider(
          create: (context) => DeleteCategoryBloc(FirebaseExpenseRepo()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Quản lý danh mục',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                });
              },
              child: Text(
                isEditMode ? 'Xong' : 'Chỉnh sửa',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Chi tiêu'),
                  Tab(text: 'Thu nhập'),
                ],
              ),
            ),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            // Create Category Listener
            BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  context.read<GetCategoriesBloc>().add(GetCategories());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tạo danh mục thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is CreateCategoryFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Có lỗi xảy ra khi tạo danh mục'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            // Update Category Listener
            BlocListener<UpdateCategoryBloc, UpdateCategoryState>(
              listener: (context, state) {
                if (state is UpdateCategorySuccess) {
                  context.read<GetCategoriesBloc>().add(GetCategories());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật danh mục thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is UpdateCategoryFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi cập nhật: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            // Delete Category Listener
            BlocListener<DeleteCategoryBloc, DeleteCategoryState>(
              listener: (context, state) {
                if (state is DeleteCategorySuccess) {
                  context.read<GetCategoriesBloc>().add(GetCategories());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa danh mục thành công'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is DeleteCategoryFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          state.message.contains('Category đang được sử dụng')
                              ? 'Danh mục đang được sử dụng, không thể xóa'
                              : 'Lỗi xóa: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: [
              CategoryListTab(
                  type: TransactionType.expense, isEditMode: isEditMode),
              CategoryListTab(
                  type: TransactionType.income, isEditMode: isEditMode),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryListTab extends StatelessWidget {
  final TransactionType type;
  final bool isEditMode;

  const CategoryListTab({
    super.key,
    required this.type,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
      builder: (context, state) {
        if (state is GetCategoriesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetCategoriesFailure) {
          return const Center(child: Text('Có lỗi xảy ra'));
        }

        if (state is GetCategoriesSuccess) {
          final filteredCategories = state.categories
              .where((category) => category.type == type)
              .toList();

          return Column(
            children: [
              // Add Category Button
              if (!isEditMode)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => _showAddCategoryDialog(context, type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Thêm danh mục'),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),

              // Categories List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return CategoryListItem(
                      category: category,
                      isEditMode: isEditMode,
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  Future<void> _showAddCategoryDialog(
      BuildContext context, TransactionType type) async {
    final newCategory = await getCategoryCreation(context, type);
    if (newCategory != null && context.mounted) {
      context.read<CreateCategoryBloc>().add(CreateCategory(newCategory));
    }
  }
}

class CategoryListItem extends StatelessWidget {
  final Category category;
  final bool isEditMode;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: isEditMode ? null : () => _navigateToEditScreen(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Name
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Actions
              if (isEditMode) ...[
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ] else ...[
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<GetCategoriesBloc>(),
            ),
            BlocProvider(
              create: (_) => UpdateCategoryBloc(
                context.read<GetCategoriesBloc>().expenseRepository,
              ),
            ),
          ],
          child: CategoryEditScreen(category: category),
        ),
      ),
    ).then((_) {
      // Refresh list after returning
      context.read<GetCategoriesBloc>().add(GetCategories());
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn có chắc muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<DeleteCategoryBloc>()
                  .add(DeleteCategory(category.categoryId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'home':
        return Icons.home;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'bonus':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}
