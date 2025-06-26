import 'package:flutter/material.dart';

import '../entities/wallet_entity.dart';

/// Model để quản lý một ví tiền riêng biệt
class Wallet {
  String walletId; // ID duy nhất từ Firestore
  String name; // Tên ví (VD: "Tiền mặt", "Vietcombank")
  int initialBalance; // Số dư ban đầu của ví này
  String icon; // Icon đại diện cho ví
  Color color; // Màu sắc đại diện cho ví
  DateTime dateCreated; // Ngày tạo ví

  Wallet({
    required this.walletId,
    required this.name,
    required this.initialBalance,
    required this.icon,
    required this.color,
    required this.dateCreated,
  });

  /// Instance rỗng mặc định
  static final empty = Wallet(
    walletId: '',
    name: '',
    initialBalance: 0,
    icon: '',
    color: Colors.white,
    dateCreated: DateTime.now(),
  );

  Wallet copyWith({
    String? walletId,
    String? name,
    int? initialBalance,
    String? icon,
    Color? color,
    DateTime? dateCreated,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  /// Chuyển đổi sang Entity để lưu Firebase
  WalletEntity toEntity() {
    return WalletEntity(
      walletId: walletId,
      name: name,
      initialBalance: initialBalance,
      icon: icon,
      color: color,
      dateCreated: dateCreated,
    );
  }

  /// Tạo từ Entity
  static Wallet fromEntity(WalletEntity entity) {
    return Wallet(
      walletId: entity.walletId,
      name: entity.name,
      initialBalance: entity.initialBalance,
      icon: entity.icon,
      color: entity.color,
      dateCreated: entity.dateCreated,
    );
  }
}
