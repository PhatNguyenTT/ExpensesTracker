import 'package:flutter/material.dart';
import '../entities/category_entity.dart';
import 'transaction_type.dart' as tt; // 👈 Import để dùng TransactionType

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  Color color;
  tt.TransactionType type; // 👈 Thêm loại danh mục: chi tiêu / thu nhập

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    required this.type, // 👈
  });

  Category copyWith({
    String? categoryId,
    String? name,
    String? icon,
    Color? color,
    tt.TransactionType? type,
    int? totalExpenses,
  }) {
    return Category(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      totalExpenses: totalExpenses ?? this.totalExpenses,
    );
  }

  static final empty = Category(
    categoryId: '',
    name: '',
    totalExpenses: 0,
    icon: '',
    color: Colors.white,
    type: tt.TransactionType.expense, // 👈 mặc định là chi tiêu
  );

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      totalExpenses: totalExpenses,
      icon: icon,
      color: color,
      type: type.toJson(), // 👈 convert to string để lưu Firestore
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      name: entity.name,
      totalExpenses: entity.totalExpenses,
      icon: entity.icon,
      color: entity.color,
      type: tt.TransactionTypeExtension.fromString(
          entity.type), // 👈 convert lại enum
    );
  }
}
