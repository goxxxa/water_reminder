import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:water_reminder/data/datasourses/firebase/firebase_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseService _database = FirebaseService();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userWeightController = TextEditingController();
  final TextEditingController _userWaterTargetController =
      TextEditingController();

  late String _userName = '';
  late String _userWeight = '';
  late String _userWaterTarget = '';

  static const double borderRadius = 12.0;

  @override
  void initState() {
    initTextEditingControllers();
    super.initState();
  }

  void initTextEditingControllers() async {
    _userName = await _database.getUserName();
    _userWeight = await _database.getUserWeight();
    _userWaterTarget = await _database.getUserTarget();
    setState(() {
      _userNameController.text = _userName;
      _userWeightController.text = _userWeight;
      _userWaterTargetController.text = _userWaterTarget;
    });
  }

  bool isChanged() => !(_userNameController.text == _userName &&
      _userWeightController.text == _userWeight &&
      _userWaterTargetController.text == _userWaterTarget);

  void updateUserData() {
    Map<String, dynamic> toUpdate = {};

    if (_userNameController.text != _userName) {
      toUpdate['name'] = _userNameController.text;
    }
    if (_userWeightController.text != _userWeight) {
      toUpdate['weight'] = _userWeightController.text;
    }
    if (_userWaterTargetController.text != _userWaterTarget) {
      toUpdate['target'] = _userWaterTargetController.text;
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
            TextField(
                controller: _userNameController,
                onChanged: (text) {
                  setState(() {
                    _userNameController.text = text;
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
            TextField(
                controller: _userWeightController,
                onChanged: (text) {
                  setState(() {
                    _userWeightController.text = text;
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
            TextField(
                controller: _userWaterTargetController,
                onChanged: (text) {
                  setState(() {
                    _userWaterTargetController.text = text;
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
