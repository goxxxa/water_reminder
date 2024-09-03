import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:water_reminder/data/models/water_container_data.dart';

import '../../../data/datasourses/firebase/firebase_service.dart';
import '../../../data/models/enums/enumerates.dart';

class ExpenseManager extends StatefulWidget {
  const ExpenseManager(
      {required this.operationType,
      this.value,
      this.date,
      this.time,
      super.key});
  final Operations operationType;
  final int? value;
  final String? date;
  final String? time;

  @override
  State<ExpenseManager> createState() => _ExpenseManagerState();
}

class _ExpenseManagerState extends State<ExpenseManager> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final FirebaseService _databaseService = FirebaseService();

  bool doTimer = true;

  final List<int> waterContainers =
      List.generate(200, (index) => (index + 1) * 50);
  static const double waterContainerHeight = 50;
  static const double waterContainersBuilderHeight = waterContainerHeight * 3;

  late int _highlightedIndex;

  static const double borderRadius = 12;

  Timer? _timer;
  @override
  void initState() {
    widget.operationType == Operations.add
        ? _highlightedIndex =
            (waterContainersBuilderHeight / 2) ~/ waterContainerHeight - 2
        : _highlightedIndex = (widget.value! ~/ waterContainerHeight) - 2;

    _dateController.text = DateFormat('dd/MM/yy').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm:ss').format(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (doTimer) {
        setState(() {
          _timeController.text = DateFormat('HH:mm').format(DateTime.now());
        });
      }
    });

    if (widget.operationType == Operations.edit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(
            waterContainerHeight * _highlightedIndex); //(widget.value!));
      });
    }

    _scrollController.addListener(_onScroll);

    super.initState();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final centerX = offset + waterContainersBuilderHeight / 2;

    for (int i = 0; i < waterContainers.length; ++i) {
      if (i * waterContainerHeight < centerX &&
          (i + 1) * waterContainerHeight > centerX) {
        setState(() {
          _highlightedIndex = i;
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Добавить воду',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: 32.0),
        child: Column(
          children: [
            const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Выберите предложенный объём',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
                )),
            const SizedBox(
              height: 8.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: waterContainersBuilderHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: waterContainers.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        height: waterContainerHeight,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        child: Center(
                          child: Text(
                            '${waterContainers[index]}',
                            style: TextStyle(
                              color: _highlightedIndex == index
                                  ? Colors.black
                                  : Colors.blue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: waterContainersBuilderHeight / 2 - 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16.0 * 2,
            ),
            Column(
              children: [
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)));
                    if (newDate != null) {
                      setState(() {
                        _dateController.text =
                            DateFormat('MM/dd/yy').format(newDate);
                      });
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(CupertinoIcons.calendar),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none)),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _timeController,
                  onTap: () async {
                    TimeOfDay? newTime = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (newTime != null) {
                      setState(() {
                        doTimer = false;
                        _timeController.text = formatTime(newTime);
                      });
                    }
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(CupertinoIcons.clock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none)),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            const Spacer(),
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
                    _databaseService
                        .addItem(
                            'users/',
                            WaterContainer(
                                size: waterContainers[_highlightedIndex]
                                    .toString(),
                                date: _dateController.text,
                                time: _timeController.text))
                        .then((value) => {Navigator.pop(context)});
                  },
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
