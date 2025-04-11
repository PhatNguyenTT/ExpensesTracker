import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

/// Định dạng số tiền Việt Nam.
/// - amount > 0: "500.000₫" hoặc "+500.000₫"
/// - amount < 0: "-200.000₫"
/// [showPlusSign] mặc định là false — chỉ hiện dấu cộng khi cần
String formatSignedCurrency(int amount, {bool showPlusSign = false}) {
  final formatted = _currencyFormatter.format(amount.abs());

  if (amount < 0) return '-$formatted';
  if (amount > 0 && showPlusSign) return '+$formatted';
  return formatted;
}

/// Màu của số tiền: dương là xanh, âm là đỏ
Color getAmountColor(int amount) {
  return amount >= 0 ? Colors.green : Colors.red;
}
