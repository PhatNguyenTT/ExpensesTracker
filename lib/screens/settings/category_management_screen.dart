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
            BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  context.read<GetCategoriesBloc>().add(GetCategories());
                }
              },
            ),
            BlocListener<UpdateCategoryBloc, UpdateCategoryState>(
              listener: (context, state) {
                if (state is UpdateCategorySuccess) {
                  context.read<GetCategoriesBloc>().add(GetCategories());
                }
              },
            ),
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
                      content: Text(state.message
                              .contains('Category đang được sử dụng')
                          ? 'Không thể xóa danh mục. Danh mục đang được sử dụng bởi các giao dịch.'
                          : 'Có lỗi xảy ra: ${state.message}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList(TransactionType.expense),
              _buildCategoryList(TransactionType.income),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(TransactionType type) {
    return BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
      builder: (context, state) {
        if (state is GetCategoriesSuccess) {
          final filteredCategories =
              state.categories.where((cat) => cat.type == type).toList();

          return Column(
            children: [
              // Nút "Thêm danh mục"
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Thêm danh mục',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Danh sách categories
              Expanded(
                child: isEditMode
                    ? _buildReorderableList(filteredCategories, type)
                    : _buildNormalList(filteredCategories),
              ),
            ],
          );
        } else if (state is GetCategoriesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        } else {
          return const Center(
            child: Text(
              'Có lỗi xảy ra',
              style: TextStyle(color: Colors.black87),
            ),
          );
        }
      },
    );
  }

  Widget _buildNormalList(List<Category> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryItem(category, false);
      },
    );
  }

  Widget _buildReorderableList(
      List<Category> categories, TransactionType type) {
    return ReorderableListView.builder(
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = categories.removeAt(oldIndex);
          categories.insert(newIndex, item);
        });
        // TODO: Implement API call to update order
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryItem(category, true,
            key: Key(category.categoryId));
      },
    );
  }

  Widget _buildCategoryItem(Category category, bool isEditMode, {Key? key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _showEditCategoryDialog(context, category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Drag handle cho edit mode
              if (isEditMode) ...[
                Icon(
                  Icons.drag_handle,
                  color: Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],

              // Category Icon
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

              // Category Name
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              if (isEditMode) ...[
                // Delete button trong edit mode
                IconButton(
                  onPressed: () => _showDeleteCategoryDialog(context, category),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ] else ...[
                // Arrow icon cho normal mode
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
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
      case 'freelance':
        return Icons.computer;
      case 'gas':
        return Icons.local_gas_station;
      case 'phone':
        return Icons.phone;
      case 'electric':
        return Icons.electrical_services;
      case 'water':
        return Icons.water_drop;
      case 'cosmetics':
        return Icons.face_retouching_natural;
      case 'clothes':
        return Icons.checkroom;
      case 'social':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  Future<void> _showAddCategoryDialog(
      BuildContext context, TransactionType type) async {
    final newCategory = await getCategoryCreation(context, type);
    if (newCategory != null) {
      context.read<CreateCategoryBloc>().add(CreateCategory(newCategory));
    }
  }

  Future<void> _showEditCategoryDialog(
      BuildContext context, Category category) async {
    final editedCategory = await getCategoryEdit(context, category);
    if (editedCategory != null) {
      context.read<UpdateCategoryBloc>().add(UpdateCategory(editedCategory));
    }
  }

  void _showDeleteCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Xóa danh mục',
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black54, fontSize: 16),
                children: [
                  const TextSpan(text: 'Bạn có chắc chắn muốn xóa danh mục '),
                  TextSpan(
                    text: '"${category.name}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nếu danh mục đang được sử dụng bởi các giao dịch, bạn cần xóa các giao dịch đó trước.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<DeleteCategoryBloc>()
                  .add(DeleteCategory(category.categoryId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
