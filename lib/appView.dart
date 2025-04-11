import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/get/get_expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home/views/homeScreen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Money Tracker",
      theme: ThemeData(
          colorScheme: ColorScheme.light(
        surface: Colors.grey.shade100,
        onSurface: Colors.black,
        primary: const Color(0xFF00B2E7),
        secondary: const Color(0xFFE064F7),
        tertiary: const Color(0xFFFF8D6C),
        outline: Colors.grey,
      )),
      home: BlocProvider(
        create: (context) =>
            GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpenses()),
        child: const HomeScreen(),
      ),
    );
  }
}
