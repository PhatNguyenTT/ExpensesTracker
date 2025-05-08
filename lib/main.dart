import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expenses_tracker/simple_bloc_observer.dart';
import 'package:expenses_tracker/app.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Khởi tạo dữ liệu ngôn ngữ
  await initializeDateFormatting(
      'vi_VN', null); // Hoặc 'en_US' nếu bạn muốn tiếng Anh

  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
