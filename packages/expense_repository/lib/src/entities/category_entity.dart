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

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color.value,
      'type': type, // 👈 lưu type
    };
  }

  static CategoryEntity fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      totalExpenses: json['totalExpenses'] as int,
      icon: json['icon'] as String,
      color: Color(json['color'] as int),
      type: json['type'] as String, // 👈
    );
  }
}
