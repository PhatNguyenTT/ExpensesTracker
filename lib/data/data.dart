import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


List<Map<String, dynamic>> transactionsData = [
  {
    'icon': const FaIcon(FontAwesomeIcons.burger, color: Colors.white,),
    'color': Colors.yellow[700],
    'name': 'Đồ ăn',
    'totalAmount': '-25.000\₫',
    'date': 'Hôm nay',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.bagShopping, color: Colors.white),
    'color': Colors.purple,
    'name': 'Mua sắm',
    'totalAmount': '-200.000\₫',
    'date': 'Hôm nay',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.heartCircleCheck, color: Colors.white),
    'color': Colors.green,
    'name': 'Sức khỏe',
    'totalAmount': '-650.000\₫',
    'date': 'Hôm qua',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.plane, color: Colors.white),
    'color': Colors.blue,
    'name': 'Du lịch',
    'totalAmount': '-1.050.000\₫',
    'date': 'Hôm qua',
  },
];