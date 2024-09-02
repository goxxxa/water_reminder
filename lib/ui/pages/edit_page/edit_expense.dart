import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChangeExpanse extends StatefulWidget {
  const ChangeExpanse({super.key});

  @override
  State<ChangeExpanse> createState() => _ChangeExpanseState();
}

class _ChangeExpanseState extends State<ChangeExpanse> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController inputWaterController = TextEditingController();

  final database = FirebaseDatabase.instance.ref();

  bool doTimer = true;
  bool enableBorder = false;
  bool _validate = false;

  final List<String> listOfWater = <String>[
    '150',
    '250',
    '350',
    '550',
    '700',
  ];

  String _errorText = '';

  Timer? _timer;
  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yy').format(DateTime.now());
    timeController.text = DateFormat('HH:mm').format(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (doTimer) {
        setState(() {
          timeController.text = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void hui(bool logic) {
    setState(() {
      enableBorder = logic;
    });
  }

  Widget test_build_container(BuildContext context, int index) {
    String buttonText = listOfWater[index];

    return Container(
      width: 100,
      height: 55,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: enableBorder ? Colors.green : Colors.transparent,
              width: 5),
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ], transform: const GradientRotation(pi / 2))),
      child: TextButton(
        onPressed: () => {hui(true), inputWaterController.text = buttonText},
        child: Text(
          '$buttonText ml',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final waterConsRef = database.child('users/12345/water/');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text(
          'Редактирование записи',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Редактирование',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  test_build_container(context, 0),
                  test_build_container(context, 1),
                  test_build_container(context, 2)
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  test_build_container(context, 3),
                  test_build_container(context, 4)
                ],
              )
            ]),
          ),
          const Text(
            'или',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Введите вручную',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.normal))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: inputWaterController,
                  onTap: () {
                    setState(() {
                      _validate = false;
                    });
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(CupertinoIcons.add),
                      errorText:
                          _validate ? "Ячейка не может быть пустой" : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 35.0),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () => {
                    showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)))
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(CupertinoIcons.calendar),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none)),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  readOnly: true,
                  controller: timeController,
                  onTap: () async {
                    TimeOfDay? newTime = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (newTime != null) {
                      setState(() {
                        doTimer = false;
                        timeController.text = formatTime(newTime);
                      });
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(CupertinoIcons.clock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.tertiary,
                      ], transform: const GradientRotation(pi / 2))),
                  child: TextButton(
                      onPressed: () async {
                        if (inputWaterController.text.isEmpty) {
                          setState(() {
                            _validate = true;
                          });
                        } else {
                          await waterConsRef.update({
                            '${dateController.text.replaceAll('/', '_')}/${timeController.text}':
                                inputWaterController.text
                          }).then((value) => {Navigator.pop(context)});
                        }
                      },
                      child: const Text(
                        'Сохранить',
                        style: TextStyle(color: Colors.white),
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
