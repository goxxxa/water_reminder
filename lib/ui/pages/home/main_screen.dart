import 'dart:async';
import 'dart:math';

import 'package:countup/countup.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:water_reminder/data/datasourses/firebase/firebase_service.dart';
import 'package:water_reminder/data/models/water_container_data.dart';
import 'package:water_reminder/ui/pages/expanse_manager/expense_manager_page.dart';
import 'package:water_reminder/ui/pages/settings/settings_page.dart';
import 'package:water_reminder/utils/string_formater.dart';

import '../../../data/models/enums/ducks_type.dart';
import '../../../data/models/enums/operations.dart';

class DuckData {
  DucksType type;
  bool isAnimated;

  DuckData({required this.type, required this.isAnimated});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseService _databaseService = FirebaseService();

  static const Duration animationDuration = Duration(seconds: 2);
  static const Duration skeletonizerDuration = Duration(milliseconds: 500);

  List<WaterContainer> waterContainers = [];
  List<DuckData> duckContainers = [];

  double beginValue = 0;
  double endValue = 0;

  int totalWaterConsumption = 0;

  final Random randomNumber = Random();

  void getTotalWaterConsumption() {
    int waterConsumption = 0;
    for (WaterContainer waterContainer in waterContainers) {
      waterConsumption += int.parse(waterContainer.size);
    }
    totalWaterConsumption = waterConsumption;
  }

  void sort() {
    waterContainers.sort((first, second) {
      DateTime thisTime = DateFormat('dd/MM/yy HH:mm')
          .parse('${first.date.replaceAll('_', '/')} ${first.time}');
      DateTime otherTime = DateFormat('dd/MM/yy HH:mm')
          .parse('${second.date.replaceAll('_', '/')} ${second.time}');
      return thisTime.compareTo(otherTime);
    });
    waterContainers = waterContainers.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 20.0, left: 20.0, right: 20.0, bottom: 3.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FutureBuilder(
                        future:
                            Future.delayed(const Duration(milliseconds: 2500)),
                        builder: (context, snapshot) {
                          String imageUrl =
                              'https://luminarix.space/assets/images/greeting_duck.webp';
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            imageUrl =
                                'https://luminarix.space/assets/images/greeting_duck_stopped.png';
                          }
                          return CachedNetworkImage(
                              width: 64,
                              height: 64,
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator());
                        }),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Привет,",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        StreamBuilder<String>(
                            stream: _databaseService.userNameStream,
                            builder: (context, snapshot) {
                              return Skeletonizer(
                                  enabled: !snapshot.hasData,
                                  enableSwitchAnimation: true,
                                  switchAnimationConfig:
                                      const SwitchAnimationConfig(
                                          duration: skeletonizerDuration),
                                  child: SizedBox(
                                    width: 80,
                                    height: 27,
                                    child: Text(
                                      snapshot.hasData
                                          ? snapshot.data.toString()
                                          : BoneMock.name,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ));
                            }),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.settings),
                  onPressed: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const Settings()))
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(25)),
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: StreamBuilder(
                          stream: _databaseService.userWaterConsumptionStream,
                          builder: (context, waterConsumpSnapshot) {
                            return StreamBuilder(
                              stream: _databaseService.userWaterTargetStream,
                              builder: (context, waterTargetSnapshot) {
                                return AnimatedContainer(
                                  duration: animationDuration,
                                  height: waterConsumpSnapshot.hasData &&
                                          waterTargetSnapshot.hasData
                                      ? ((MediaQuery.of(context).size.width /
                                                  2) *
                                              int.parse(waterConsumpSnapshot
                                                  .data
                                                  .toString())) /
                                          int.parse(waterTargetSnapshot.data
                                              .toString())
                                      : 0,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                      Theme.of(context).colorScheme.tertiary,
                                    ],
                                  )),
                                );
                              },
                            );
                          }),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        StreamBuilder(
                            stream: _databaseService.userWaterConsumptionStream,
                            builder: (context, snapshot) {
                              beginValue = endValue;
                              endValue = snapshot.hasData
                                  ? snapshot.data!.toDouble()
                                  : 0;

                              return Countup(
                                begin: beginValue,
                                end: endValue,
                                suffix: ' мл',
                                duration: animationDuration,
                                separator: '.',
                                style: const TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold),
                              );
                            }),
                        StreamBuilder(
                          stream: _databaseService.userWaterTargetStream,
                          builder: (context, snapshot) {
                            return Skeletonizer(
                              enabled: !snapshot.hasData,
                              enableSwitchAnimation: true,
                              switchAnimationConfig:
                                  const SwitchAnimationConfig(
                                      duration: Duration(
                                milliseconds: 300,
                              )),
                              child: Text(
                                snapshot.hasData
                                    ? '/${snapshot.data}'
                                    : '10000',
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ])),
            const SizedBox(
              height: 15.0,
            ),
            const Row(
              children: [
                Text(
                  'История',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _databaseService.userWaterContainersStream,
                builder: (context, snapshot) {
                  waterContainers = snapshot.data ??
                      List.filled(
                        4,
                        WaterContainer(
                            size: BoneMock.title,
                            date: BoneMock.date,
                            time: BoneMock.time),
                      );
                  if (snapshot.hasData) {
                    sort();
                    getTotalWaterConsumption();
                  }
                  return snapshot.hasData && waterContainers.isNotEmpty
                      ? Skeletonizer(
                          enabled: !snapshot.hasData,
                          enableSwitchAnimation: true,
                          switchAnimationConfig: const SwitchAnimationConfig(
                            duration: Duration(milliseconds: 400),
                          ),
                          child: ListView.separated(
                            itemCount: waterContainers.length,
                            separatorBuilder: (context, int index) {
                              if (waterContainers[index].date !=
                                  waterContainers[index + 1].date) {
                                return SizedBox(
                                  height: 24,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(waterContainers[index + 1]
                                        .date
                                        .dateFormaterFromDatabase()),
                                  ),
                                );
                              }
                              return const Divider(
                                color: Colors.transparent,
                                height: 12,
                              );
                            },
                            itemBuilder: (context, int index) {
                              return RepaintBoundary(
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Dismissible(
                                        key: ValueKey<WaterContainer>(
                                            waterContainers[index]),
                                        onDismissed:
                                            (DismissDirection direction) => {
                                          _databaseService.removeItem(
                                              waterContainers[index])
                                        },
                                        dismissThresholds: const {
                                          DismissDirection.endToStart: 0.7
                                        },
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                          ),
                                          child:
                                              const Icon(CupertinoIcons.delete),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 0.0),
                                          child: GestureDetector(
                                            onDoubleTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<void>(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ExpenseManager(
                                                          time:
                                                              waterContainers[
                                                                      index]
                                                                  .time,
                                                          date:
                                                              waterContainers[
                                                                      index]
                                                                  .date,
                                                          value: int.parse(
                                                              waterContainers[
                                                                      index]
                                                                  .size),
                                                          operationType:
                                                              Operations.edit),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        StreamBuilder<int>(
                                                          stream: _databaseService
                                                              .userWaterConsumptionStream,
                                                          builder: (context,
                                                              snapshot) {
                                                            final activeDuckTypes =
                                                                DucksType.values
                                                                    .where(
                                                                      (type) =>
                                                                          !type.toString().endsWith(
                                                                              'Stopped') &&
                                                                          !type
                                                                              .toString()
                                                                              .split('.')[1]
                                                                              .startsWith('exploding'),
                                                                    )
                                                                    .toList();
                                                            final randomDuckType =
                                                                activeDuckTypes[
                                                                    Random().nextInt(
                                                                        activeDuckTypes
                                                                            .length)];
                                                            String imageUrl =
                                                                'https://luminarix.space/assets/images/${randomDuckType.name}.webp';

                                                            return snapshot
                                                                        .hasData &&
                                                                    snapshot.data! >=
                                                                        1000
                                                                ? FutureBuilder(
                                                                    future: Future.delayed(const Duration(
                                                                        seconds:
                                                                            3)),
                                                                    builder:
                                                                        (context,
                                                                            futureSnapshot) {
                                                                      imageUrl =
                                                                          'https://luminarix.space/assets/images/exploding_duck.webp';
                                                                      if (futureSnapshot
                                                                              .connectionState ==
                                                                          ConnectionState
                                                                              .done) {
                                                                        imageUrl =
                                                                            'https://luminarix.space/assets/images/${randomDuckType.name}.webp';
                                                                      }

                                                                      return CachedNetworkImage(
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                        imageUrl:
                                                                            imageUrl,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const CircularProgressIndicator(),
                                                                      );
                                                                    })
                                                                : CachedNetworkImage(
                                                                    width: 50,
                                                                    height: 50,
                                                                    imageUrl:
                                                                        imageUrl,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            const CircularProgressIndicator(),
                                                                  );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 20.0),
                                                        Text(
                                                          waterContainers
                                                                  .isNotEmpty
                                                              ? '${waterContainers[index].size} мл'
                                                              : BoneMock.name,
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(waterContainers
                                                                .isNotEmpty
                                                            ? waterContainers[
                                                                    index]
                                                                .date
                                                                .dateFormaterFromDatabase()
                                                            : BoneMock.date),
                                                        Text(waterContainers
                                                                .isNotEmpty
                                                            ? waterContainers[
                                                                    index]
                                                                .time
                                                            : BoneMock.time)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Тут пока ничего нет...',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
