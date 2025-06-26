import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Entity để lưu trữ thông tin ví trên Firestore
class WalletEntity {
  String walletId;
  String name;
  int initialBalance;
  String icon;
  Color color;
  DateTime dateCreated;

  WalletEntity({
    required this.walletId,
    required this.name,
    required this.initialBalance,
    required this.icon,
    required this.color,
    required this.dateCreated,
  });

  Map<String, Object?> toJson() {
    return {
      'walletId': walletId,
      'name': name,
      'initialBalance': initialBalance,
      'icon': icon,
      'color': color.value,
      'dateCreated': dateCreated,
    };
  }

  static WalletEntity fromJson(Map<String, dynamic> json) {
    return WalletEntity(
      walletId: json['walletId'] as String,
      name: json['name'] as String,
      initialBalance: json['initialBalance'] as int,
      icon: json['icon'] as String,
      color: Color(json['color'] as int),
      dateCreated: (json['dateCreated'] as Timestamp).toDate(),
    );
  }
}
