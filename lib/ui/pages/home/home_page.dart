import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:water_reminder/data/datasourses/firebase/firebase_service.dart';
import 'package:water_reminder/data/datasourses/telegram/telegram_service.dart';
import 'package:water_reminder/data/models/enums/operations.dart';
import 'package:water_reminder/ui/pages/expanse_manager/expense_manager_page.dart';
import '../statistics/statistic_page.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  final FirebaseService _databaseService = FirebaseService();

  final Color selectedItem = Colors.blue;
  final Color unselectedItem = Colors.grey;

  void checkUser() async {
    if (!await _databaseService
        .checkIsUserExists(TelegramService.instance.userId)) {
      _databaseService.addUser(
          TelegramService.instance.userId, TelegramService.instance.userName);
    }
  }

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 3,
            backgroundColor: Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.home,
                  color: pageIndex == 0 ? selectedItem : unselectedItem,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.graph_circle,
                      color: pageIndex == 1 ? selectedItem : unselectedItem),
                  label: 'Graph')
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: pageIndex == 0 ? true : false,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ], transform: const GradientRotation(pi / 2))),
            child: const Icon(CupertinoIcons.add),
          ),
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const ExpenseManager(
                  operationType: Operations.add,
                ),
              ),
            )
          },
        ),
      ),
      body: pageIndex == 0 ? const MainScreen() : const StatScreen(),
    );
  }
}
