import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/settings/blocs/update_category_bloc/update_category_bloc.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryEditScreen extends StatefulWidget {
  final Category category;

  const CategoryEditScreen({super.key, required this.category});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late TextEditingController categoryNameController;
  late IconData? selectedIcon;
  late Color selectedColor;
  late Category editedCategory;
  bool isLoading = false;

  // Predefined colors for the palette
  final List<List<Color>> colorPalette = [
    [
      Colors.yellow[300]!,
      Colors.pink[100]!,
      Colors.pink[300]!,
      Colors.purple[200]!,
      Colors.purple[100]!
    ],
    [
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple[300]!,
      Colors.purple
    ],
    [
      Colors.brown,
      Colors.red[900]!,
      Colors.brown[400]!,
      Colors.purple[700]!,
      Colors.deepPurple
    ],
    [
      Colors.yellow[200]!,
      Colors.lightGreen[200]!,
      Colors.green[100]!,
      Colors.teal[100]!,
      Colors.cyan[100]!
    ],
    [Colors.yellow, Colors.lightGreen, Colors.green, Colors.teal, Colors.blue],
  ];

  // Available icons
  final List<IconData> availableIcons = [
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.water_drop,
    Icons.checkroom,
    Icons.face_retouching_natural,
    Icons.directions_car,
    Icons.edit,
    Icons.medical_services,
    Icons.celebration,
    Icons.water,
    Icons.phone,
    Icons.home,
    Icons.account_balance_wallet,
    Icons.savings,
    Icons.card_giftcard,
    Icons.money,
  ];

  @override
  void initState() {
    super.initState();
    categoryNameController = TextEditingController(text: widget.category.name);
    selectedIcon = IconMapper.getIcon(widget.category.icon);
    selectedColor = widget.category.color;
    editedCategory = widget.category.copyWith();
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<UpdateCategoryBloc>(),
      child: BlocListener<UpdateCategoryBloc, UpdateCategoryState>(
        listener: (context, state) {
          if (state is UpdateCategorySuccess) {
            Navigator.pop(context, editedCategory);
          } else if (state is UpdateCategoryLoading) {
            setState(() => isLoading = true);
          } else if (state is UpdateCategoryFailure) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Có lỗi xảy ra khi cập nhật danh mục'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Chỉnh sửa',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Section
                const Text(
                  'Tên',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: categoryNameController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Nhập tên danh mục',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon Section
                const Text(
                  'Biểu tượng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = availableIcons[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedColor.withOpacity(0.2)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? selectedColor
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color:
                                isSelected ? selectedColor : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Color Section
                const Text(
                  'Màu sắc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: colorPalette.map((row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: row.map((color) {
                            final isSelected =
                                selectedColor.value == color.value;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: isSelected ? 3 : 0,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Lưu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên danh mục'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn biểu tượng'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    editedCategory = editedCategory.copyWith(
      name: categoryNameController.text.trim(),
      color: selectedColor,
      icon: IconMapper.getName(selectedIcon!) ?? 'category',
    );

    context.read<UpdateCategoryBloc>().add(UpdateCategory(editedCategory));
  }
}

// Keep the old function for compatibility
Future<Category?> getCategoryEdit(BuildContext context, Category category) {
  return Navigator.push<Category>(
    context,
    MaterialPageRoute(
      builder: (context) => CategoryEditScreen(category: category),
    ),
  );
}
