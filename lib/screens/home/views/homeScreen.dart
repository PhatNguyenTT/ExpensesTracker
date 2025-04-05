import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/addExpense.dart';
import 'package:expenses_tracker/screens/calendar/calendar.dart';
import 'package:expenses_tracker/screens/home/views/mainScreen.dart';
import 'package:expenses_tracker/screens/profile/profile.dart';
import 'package:expenses_tracker/screens/stats/stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var widgetList = [
    const MainScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            currentIndex: index,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 3,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar), label: 'Calendar'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.graph_square_fill), label: 'Stats'),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_solid), label: 'Profile')
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => BlocProvider(
                create: (context) => CreateCategoryBloc(FirebaseExpenseRepo()),
                child: const AddExpense(),
              ),
            ),
          );
        },
        shape: CircleBorder(),
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.tertiary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary,
                ],
                transform: const GradientRotation(pi / 4),
              )),
          child: const Icon(
            CupertinoIcons.add,
          ),
        ),
      ),
      body: widgetList[index],
    );
  }
}
