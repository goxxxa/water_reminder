import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:water_reminder/firebase/realtime_database.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseService _database = FirebaseService();

  TextEditingController userNameController = TextEditingController();
  TextEditingController userWeightController = TextEditingController();
  TextEditingController userWaterTargetController = TextEditingController();

  late String userName = '';
  late String userWeight = '';
  late String userWaterTarget = '';

  static const double borderRadius = 12.0;

  @override
  void initState() {
    initTextEditingControllers();
    super.initState();
  }

  void initTextEditingControllers() async {
    userName = await _database.getUserName();
    userWeight = await _database.getUserWeight();
    userWaterTarget = await _database.getUserTarget();
    setState(() {
      userNameController.text = userName;
      userWeightController.text = userWeight;
      userWaterTargetController.text = userWaterTarget;
    });
  }

  bool isChanged() {
    if (userNameController.text == userName &&
        userWeightController.text == userWeight &&
        userWaterTargetController.text == userWaterTarget) {
      return false;
    }
    return true;
  }

  void updateUserData() {
    Map<String, dynamic> toUpdate = {};

    if (userNameController.text != userName) {
      toUpdate['name'] = userNameController.text;
    }
    if (userWeightController.text != userWeight) {
      toUpdate['weight'] = userWeightController.text;
    }
    if (userWaterTargetController.text != userWaterTarget) {
      toUpdate['target'] = userWaterTargetController.text;
    }
    _database.updateItem('users/', toUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ваши данные',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
        child: Column(
          children: [
            TextFormField(
                controller: userNameController,
                onChanged: (text) {
                  setState(() {
                    userNameController.text = text;
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide.none))),
            const SizedBox(
              height: 16.0,
            ),
            TextFormField(
                controller: userWeightController,
                onChanged: (text) {
                  setState(() {
                    userWeightController.text = text;
                  });
                },
                decoration: InputDecoration(
                    suffix: const Text('кг'),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(MdiIcons.weight),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide.none))),
            const SizedBox(
              height: 24.0,
            ),
            const Text('Параметры ниже выставлены по умолчанию'),
            const SizedBox(
              height: 8.0,
            ),
            TextFormField(
                controller: userWaterTargetController,
                onChanged: (text) {
                  setState(() {
                    userWaterTargetController.text = text;
                  });
                },
                decoration: InputDecoration(
                    suffix: const Text('мл'),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(MdiIcons.target),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                        borderSide: BorderSide.none))),
            const SizedBox(
              height: 16.0,
            ),
            const Spacer(),
            Visibility(
              visible: isChanged(),
              child: Container(
                width: double.infinity,
                height: kToolbarHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                      transform: const GradientRotation(pi / 2),
                    )),
                child: TextButton(
                    onPressed: () {
                      if (isChanged()) {
                        updateUserData();
                      }

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Сохранить изменения',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}