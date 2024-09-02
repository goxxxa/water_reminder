import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:water_reminder/telegram/telegram_connection.dart';
//import 'package:water_reminder/telegram/telegram_connection.dart';
import 'package:water_reminder/utils/string_formater.dart';
//import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/water_container_data.dart';

class TimeAndSize {
  String time;
  String size;

  TimeAndSize({required this.time, required this.size});
}

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  int _waterTarget = 0;
  String _userName = '';

  bool isTelegram = kIsWeb;
  late int id;

  late TelegramData telegramConnection;

  FirebaseService() {
    if (isTelegram) {
      telegramConnection = TelegramData();
      id = telegramConnection.id;

    }
  }

  Future<void> addItem(String path, WaterContainer item) async {
    await _database
        .ref()
        .child('$path/$id/water/${item.date.dateFormatToDatabase()}')
        .update(item.toDB());
  }

  Future<void> updateItem(String path, Map<String, dynamic> item) async {
    await _database.ref().child('$path/$id').update(item);
  }

  Future<void> removeItem(WaterContainer item) async {
    await _database
        .ref()
        .child('users/$id/water/${item.date}/${item.time}')
        .remove();
  }

  Future<Map<String, dynamic>> getDataForMainChart() async {
    final DatabaseReference databaseReference =
        _database.ref().child('users/$id/water');
    final DatabaseEvent databaseEvent = await databaseReference.once();

    Map<String, dynamic> output = {};
    int container = 0;
    for (final child in databaseEvent.snapshot.children) {
      container = 0;

      for (final children in child.children) {
        container += int.parse(children.value.toString());
      }
      output[child.key.toString()] = container;
    }

    return output;
  }

  Future<List<TimeAndSize>> getListOfWaterContainers() async {
    final String currentDate = DateFormat('dd/MM/yy').format(DateTime.now());
    final DatabaseReference waterRef = _database.ref().child('users/$id/water');
    final DatabaseEvent currentWaterConsumption = await waterRef.once();

    List<TimeAndSize> waterContainers = [];
    for (final child in currentWaterConsumption.snapshot.children) {
      if (child.key == currentDate.dateFormatToDatabase()) {
        for (final element in child.children) {
          waterContainers.add(TimeAndSize(
              time: element.key.toString(), size: element.value.toString()));
        }
      }
    }

    return waterContainers;
  }

  Future<int> getWaterConsumption() async {
    final String currentDate = DateFormat('dd/MM/yy').format(DateTime.now());
    final DatabaseReference waterRef = _database.ref().child('users/$id/water');
    final DatabaseEvent currentWaterConsumption = await waterRef.once();

    int waterConsumption = 0;
    for (final child in currentWaterConsumption.snapshot.children) {
      if (child.key == currentDate.dateFormatToDatabase()) {
        waterConsumption += child.children
            .fold(0, (sum, item) => sum + int.parse(item.value.toString()));
      }
    }
    return waterConsumption;
  }

  Future<String> getUserName() async {
    DatabaseEvent userName =
        await _database.ref().child('users/$id/name').once();
    return userName.snapshot.value.toString();
  }

  Future<String> getUserWeight() async {
    DatabaseEvent userWeight =
        await _database.ref().child('users/$id/weight').once();
    return userWeight.snapshot.value.toString();
  }

  Future<String> getUserTarget() async {
    DatabaseEvent userTarget =
        await _database.ref().child('users/$id/target').once();
    return userTarget.snapshot.value.toString();
  }

  Stream<int> get userWaterConsumptionStream =>
      _database.ref().child('users/$id/water').onValue.map((event) {
        final String currentDate =
            DateFormat('dd/MM/yy').format(DateTime.now());
        int waterConsumption = 0;
        for (final child in event.snapshot.children) {
          if (child.key == currentDate.dateFormatToDatabase()) {
            waterConsumption += child.children
                .fold(0, (sum, item) => sum + int.parse(item.value.toString()));
          }
        }
        return waterConsumption;
      });

  Stream<String> get userNameStream => _database
          .ref()
          .child('users')
          .child('$id')
          .child('name')
          .onValue
          .map((event) {
        _userName = event.snapshot.value.toString();
        return _userName;
      });

  String get userName => _userName;

  Stream<int> get userWaterTargetStream => _database
          .ref()
          .child('users')
          .child('$id')
          .child('target')
          .onValue
          .map((event) {
        _waterTarget = int.parse(event.snapshot.value.toString());
        return _waterTarget;
      });

  int get waterTarget => _waterTarget;

  Stream<List<WaterContainer>> get userWaterContainersStream => _database
      .ref()
      .child('users')
      .child('$id')
      .child('water')
      .onValue
      .map((event) => event.snapshot.children
          .map((element) => element.children.map((children) => WaterContainer(
                size: children.value.toString(),
                date: element.key.toString(),
                time: children.key.toString(),
              )))
          .fold<List<WaterContainer>>(
              [], (list, element) => list..addAll(element)));
}
