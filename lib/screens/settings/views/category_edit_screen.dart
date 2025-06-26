import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/settings/blocs/update_category_bloc/update_category_bloc.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/utils/category_icon_picker.dart';

class CategoryEditScreen extends StatefulWidget {
  final Category category;

  const CategoryEditScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData? _selectedIcon;
  bool _isLoading = false;
  bool _isIconExpanded = false;
  bool _isCategoryInUse = false;
  bool _isCheckingUsage = true;
  final ScrollController _scrollController = ScrollController();
  final ExpenseRepository _repository = FirebaseExpenseRepo();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = widget.category.color;
    _selectedIcon = IconMapper.getIcon(widget.category.icon);
    _checkCategoryUsage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkCategoryUsage() async {
    try {
      final isInUse =
          await _repository.isCategoryInUse(widget.category.categoryId);
      if (mounted) {
        setState(() {
          _isCategoryInUse = isInUse;
          _isCheckingUsage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCategoryInUse = false; // Allow editing if usage check fails
          _isCheckingUsage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCategoryBloc, UpdateCategoryState>(
      listener: (context, state) {
        if (state is UpdateCategoryLoading) {
          setState(() => _isLoading = true);
        } else if (state is UpdateCategorySuccess) {
          Navigator.of(context).pop(true);
        } else if (state is UpdateCategoryFailure) {
          setState(() => _isLoading = false);
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chỉnh sửa danh mục',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: _isCheckingUsage
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Đang kiểm tra danh mục...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Warning banner if category is in use
                    if (_isCategoryInUse) _buildWarningBanner(),

                    // Name Section
                    _buildSectionTitle('Tên danh mục'),
                    const SizedBox(height: 12),
                    _buildNameField(),
                    const SizedBox(height: 24),

                    // Icon Section
                    _buildSectionTitle('Biểu tượng'),
                    const SizedBox(height: 12),
                    _buildIconField(),
                    if (_isIconExpanded && !_isCategoryInUse)
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: IconPickerGrid(
                            icons: categoryIcons,
                            scrollController: _scrollController,
                            selectedIcon: _selectedIcon,
                            onIconSelected: (icon) {
                              setState(() {
                                _selectedIcon = icon;
                                _isIconExpanded = false;
                              });
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Color Section
                    _buildSectionTitle('Màu sắc'),
                    const SizedBox(height: 12),
                    _buildColorField(),
                    const SizedBox(height: 40),

                    // Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh mục đang được sử dụng',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Danh mục này đã được sử dụng trong các giao dịch. Không thể chỉnh sửa để đảm bảo tính nhất quán dữ liệu.',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _isCategoryInUse ? Colors.grey[500] : Colors.black87,
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: _isCategoryInUse ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: _isCategoryInUse
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: _nameController,
        enabled: !_isCategoryInUse,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _isCategoryInUse ? Colors.grey[500] : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Nhập tên danh mục',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Icon(
            Icons.edit,
            color: _isCategoryInUse ? Colors.grey[400] : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildIconField() {
    return GestureDetector(
      onTap: _isCategoryInUse
          ? () => _showRestrictedMessage()
          : () {
              setState(() {
                _isIconExpanded = !_isIconExpanded;
              });
              if (_selectedIcon != null && _isIconExpanded) {
                final index =
                    categoryIcons.indexWhere((e) => e.icon == _selectedIcon);
                if (index != -1) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      (index / 4).floor() * 80,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              }
            },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isCategoryInUse ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                Radius.circular(_isIconExpanded && !_isCategoryInUse ? 0 : 16),
            bottomRight:
                Radius.circular(_isIconExpanded && !_isCategoryInUse ? 0 : 16),
          ),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: _isCategoryInUse
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            if (_selectedIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _selectedColor.withOpacity(_isCategoryInUse ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _selectedIcon,
                  color: _isCategoryInUse ? Colors.grey[400] : _selectedColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.category,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                _selectedIcon != null
                    ? 'Biểu tượng đã chọn'
                    : 'Chọn biểu tượng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isCategoryInUse
                      ? Colors.grey[500]
                      : (_selectedIcon != null
                          ? Colors.black87
                          : Colors.grey[500]),
                ),
              ),
            ),
            Icon(
              _isCategoryInUse
                  ? Icons.lock_outline
                  : (_isIconExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down),
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorField() {
    return GestureDetector(
      onTap: _isCategoryInUse
          ? () => _showRestrictedMessage()
          : () => _showColorPicker(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isCategoryInUse ? Colors.grey[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: _isCategoryInUse
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isCategoryInUse ? Colors.grey[300] : _selectedColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Tùy chỉnh màu sắc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isCategoryInUse ? Colors.grey[500] : Colors.black87,
                ),
              ),
            ),
            Icon(
              _isCategoryInUse ? Icons.lock_outline : Icons.color_lens,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (_isLoading || _isCategoryInUse)
            ? null
            : () {
                _saveCategory();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCategoryInUse ? Colors.grey[400] : Colors.black87,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey[400],
          elevation: _isCategoryInUse ? 0 : 3,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                _isCategoryInUse ? 'Không thể chỉnh sửa' : 'Lưu thay đổi',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Chọn màu sắc',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
            labelTypes: const [],
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Chọn',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestrictedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Danh mục đang được sử dụng, không thể chỉnh sửa'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Cập nhật thất bại!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Có lỗi xảy ra khi cập nhật danh mục:\n\n$errorMessage',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    // Check if save is allowed
    if (_isLoading) {
      _showValidationError('Đang xử lý, vui lòng đợi...');
      return;
    }

    if (_isCategoryInUse) {
      _showValidationError('Danh mục đang được sử dụng, không thể chỉnh sửa');
      return;
    }

    // Validation
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showValidationError('Vui lòng nhập tên danh mục');
      return;
    }

    if (name.length > 50) {
      _showValidationError('Tên danh mục không được quá 50 ký tự');
      return;
    }

    if (_selectedIcon == null) {
      _showValidationError('Vui lòng chọn biểu tượng');
      return;
    }

    if (_selectedColor == Colors.white) {
      _showValidationError('Vui lòng chọn màu sắc khác màu trắng');
      return;
    }

    // Check if any changes were made
    final hasNameChanged = name != widget.category.name;
    final hasColorChanged = _selectedColor != widget.category.color;
    final currentIconName = IconMapper.getName(_selectedIcon!);
    final hasIconChanged = currentIconName != widget.category.icon;

    if (!hasNameChanged && !hasColorChanged && !hasIconChanged) {
      _showValidationError('Không có thay đổi nào để lưu');
      return;
    }

    try {
      final iconName = IconMapper.getName(_selectedIcon!);
      if (iconName == null) {
        _showValidationError('Không thể xác định biểu tượng đã chọn');
        return;
      }

      final updatedCategory = widget.category.copyWith(
        name: name,
        color: _selectedColor,
        icon: iconName,
      );

      context.read<UpdateCategoryBloc>().add(UpdateCategory(updatedCategory));
    } catch (e) {
      _showErrorDialog('Lỗi không xác định: $e');
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
