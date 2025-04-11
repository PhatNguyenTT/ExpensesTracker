import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/screens/addExpense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/utils/category_icon_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

Future<Category?> getCategoryCreation(
    BuildContext context, tt.TransactionType type) {
  return showDialog<Category>(
    context: context,
    builder: (ctx) {
      IconData? selectedIcon;
      Color categoryColor = Colors.white;
      bool isExpanded = false;
      TextEditingController categoryNameController = TextEditingController();
      bool isLoading = false;
      Category category = Category.empty;
      final scrollController = ScrollController();

      return BlocProvider.value(
        value: context.read<CreateCategoryBloc>(),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  Navigator.pop(ctx, category);
                } else if (state is CreateCategoryLoading) {
                  setState(() => isLoading = true);
                }
              },
              child: AlertDialog(
                title: const Text('Tạo Danh mục mới'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: categoryNameController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Tên',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          onTap: () {
                            setState(() => isExpanded = !isExpanded);
                            if (selectedIcon != null) {
                              final index = categoryIcons
                                  .indexWhere((e) => e.icon == selectedIcon);
                              if (index != -1) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  scrollController.animateTo(
                                    (index / 4).floor() * 80,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              }
                            }
                          },
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            prefixIcon: selectedIcon != null
                                ? Icon(
                                    selectedIcon,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: 20,
                                  )
                                : null,
                            suffixIcon: const Icon(CupertinoIcons.chevron_down,
                                size: 12),
                            fillColor: Colors.white,
                            hintText: 'Icon',
                            border: OutlineInputBorder(
                              borderRadius: isExpanded
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(12))
                                  : BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        if (isExpanded)
                          Container(
                            height: 240,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconPickerGrid(
                                scrollController: scrollController,
                                selectedIcon: selectedIcon,
                                onIconSelected: (icon) {
                                  setState(() {
                                    selectedIcon = icon;
                                    isExpanded = false;
                                  });
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        TextField(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx2) => AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ColorPicker(
                                      pickerColor: categoryColor,
                                      onColorChanged: (value) {
                                        setState(() => categoryColor = value);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(ctx2),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Lưu',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: categoryColor,
                            hintText: 'Màu sắc',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: kToolbarHeight,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      category.categoryId = const Uuid().v1();
                                      category.name =
                                          categoryNameController.text;
                                      category.color = categoryColor;
                                      category.icon =
                                          IconMapper.getName(selectedIcon!)!;
                                      category.type = type;
                                    });
                                    context
                                        .read<CreateCategoryBloc>()
                                        .add(CreateCategory(category));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lưu',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
