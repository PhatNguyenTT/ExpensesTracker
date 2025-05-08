import 'package:flutter/material.dart';

class CategoryEntity {
  final String categoryId;
  final String name;
  final int totalExpenses;
  final String icon;
  final Color color;
  final String type; // 👈 thêm trường này để lưu enum dưới dạng string

  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
    required this.type, // 👈
  });

  Map<String, dynamic> toDocument() {
    return {
      'categoryId': categoryId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color.value,
      'type': type, // 👈 lưu type
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryEntity(
      categoryId: doc['categoryId'] as String,
      name: doc['name'] as String,
      totalExpenses: doc['totalExpenses'] as int,
      icon: doc['icon'] as String,
      color: Color(doc['color'] as int),
      type: doc['type'] as String, // 👈
    );
  }
}
