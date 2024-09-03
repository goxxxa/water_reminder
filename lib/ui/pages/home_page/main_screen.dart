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
import 'package:water_reminder/ui/pages/expanse_manager_page/expense_manager.dart';
import 'package:water_reminder/ui/pages/settings_page/settings.dart';
import 'package:water_reminder/utils/string_formater.dart';

import '../../../data/models/enums/ducks_type.dart';
import '../../../data/models/enums/operations.dart';

class GifPlayer extends StatelessWidget {
  final String fileName;
  const GifPlayer({required this.fileName, super.key});

  void stop() {}

  void play() {}

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(imageUrl: fileName);
  }
}

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

  void test() {}

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

  String dateValidator(String date) {
    final timeNow = DateFormat('dd_MM_yy').format(DateTime.now());

    if (timeNow == date) {
      return 'Сегодня';
    }

    List splittedDate = date.split('_');
    List splittedTimeNow = timeNow.split('_');
    if (splittedDate[2] == splittedTimeNow[2] &&
        splittedDate[1] == splittedTimeNow[1]) {
      int first = int.parse(splittedDate[0]);
      int second = int.parse(splittedTimeNow[0]);
      int result = second - first;

      switch (result) {
        case 1:
          return 'Вчера';
        case 2:
          return 'Позавчера';
      }
    }

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(
          top: 20.0, left: 20.0, right: 20.0, bottom: 3.0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FutureBuilder(
                    //8560
                    future: Future.delayed(const Duration(milliseconds: 2500)),
                    builder: (context, snapshot) {
                      String imageUrl =
                          'https://luminarix.space/assets/images/greeting_duck.webp';
                      if (snapshot.connectionState == ConnectionState.done) {
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
                        builder: (BuildContext context) => const Settings()))
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
                                  ? ((MediaQuery.of(context).size.width / 2) *
                                          int.parse(waterConsumpSnapshot.data
                                              .toString())) /
                                      int.parse(
                                          waterTargetSnapshot.data.toString())
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
                          endValue =
                              snapshot.hasData ? snapshot.data!.toDouble() : 0;

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
                          switchAnimationConfig: const SwitchAnimationConfig(
                              duration: Duration(
                            milliseconds: 300,
                          )),
                          child: Text(
                            snapshot.hasData ? '/${snapshot.data}' : '10000',
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
                              time: BoneMock.time));
                  if (snapshot.hasData) {
                    sort();
                    getTotalWaterConsumption();
                  }

                  return snapshot.hasData && waterContainers.isNotEmpty
                      ? Skeletonizer(
                          enabled: !snapshot.hasData,
                          enableSwitchAnimation: true,
                          switchAnimationConfig: const SwitchAnimationConfig(
                              duration: Duration(milliseconds: 400)),
                          child: ListView.separated(
                            itemCount: waterContainers.length,
                            separatorBuilder: (context, int index) {
                              if (waterContainers[index].date !=
                                  waterContainers[index + 1].date) {
                                return SizedBox(
                                  height: 24,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(dateValidator(
                                        waterContainers[index + 1].date)),
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
                                                              value: int.parse(
                                                                  waterContainers[
                                                                          index]
                                                                      .size),
                                                              operationType:
                                                                  Operations
                                                                      .edit)));
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
                                                              final activeDuckTypes = DucksType
                                                                  .values
                                                                  .where((type) =>
                                                                      !type
                                                                          .toString()
                                                                          .endsWith(
                                                                              'Stopped') &&
                                                                      !type
                                                                          .toString()
                                                                          .split('.')[
                                                                              1]
                                                                          .startsWith(
                                                                              'exploding'))
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
                                                                        if (futureSnapshot.connectionState ==
                                                                            ConnectionState.done) {
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
                                                                          placeholder: (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                        );
                                                                      })
                                                                  : CachedNetworkImage(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      imageUrl:
                                                                          imageUrl,
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                    );
                                                            }),
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
                          child: Text('Тут пока ничего нет...',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        );
                }))
      ]),
    ));
  }
}

// class WaveBackground extends StatefulWidget {
//   const WaveBackground({Key? key}) : super(key: key);

//   @override
//   State<WaveBackground> createState() => _WaveBackgroundState();
// }

// class _WaveBackgroundState extends State<WaveBackground>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     );
//     _controller.repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildAnimation(BuildContext context, Widget? widget) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.height,
//       height: 10,
//       child: CustomPaint(
//         painter:
//             WavePainter(controller: _controller, waves: 4, waveAmplitude: 15),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: _buildAnimation,
//     );
//   }
// }

// class WavePainter extends CustomPainter {
//   late final Animation<double> position;
//   final Animation<double> controller;

//   final int waves;

//   final double waveAmplitude;
//   int get waveSegments => 2 * waves - 1;

//   WavePainter(
//       {required this.controller,
//       required this.waves,
//       required this.waveAmplitude}) {
//     position = Tween(begin: 0.0, end: 1.0)
//         .chain(CurveTween(curve: Curves.linear))
//         .animate(controller);
//   }

//   void drawWave(Path path, int wave, size) {
//     double waveWidth = size.width / waveSegments;
//     double waveMinHeight = size.height / 2;

//     double x1 = wave * waveWidth + waveWidth / 2;
//     // Minimum and maximum height points of the waves.
//     double y1 = waveMinHeight + (wave.isOdd ? waveAmplitude : -waveAmplitude);

//     double x2 = x1 + waveWidth / 2;
//     double y2 = waveMinHeight;

//     path.quadraticBezierTo(x1, y1, x2, y2);
//     if (wave <= waveSegments) {
//       drawWave(path, wave + 1, size);
//     }
//   }

//   @override
//   void paint(Canvas canvas, size) {
//     Paint paint = Paint()
//       ..color = Colors.lightBlue
//       ..style = PaintingStyle.fill;

//     // Draw the waves
//     Path path = Path()..moveTo(0, size.height / 2);
//     drawWave(path, 0, size);

//     // Draw lines to the bottom corners of the size/screen with account for one extra wave.
//     double waveWidth = (size.width / waveSegments) * 2;
//     path
//       ..lineTo(size.width + waveWidth, size.height)
//       ..lineTo(0, size.height)
//       ..lineTo(0, size.height / 2)
//       ..close();

//     // Animate sideways one wave length, so it repeats cleanly.
//     Path shiftedPath = path.shift(Offset(-position.value * waveWidth, 0));

//     canvas.drawPath(shiftedPath, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }

// class LiquidAnimation extends StatefulWidget {
//   LiquidAnimationState createState() => LiquidAnimationState();
// }

// const _numberOfWavePoints = 11;

// class LiquidAnimationMap {
//   List<double> heightMap;
//   List<double> velocityMap;

//   LiquidAnimationMap({required this.heightMap, required this.velocityMap});

//   updateMaps(double timeInterval) {
//     const speed = 15.0;
//     const acceleration = 15.0;
//     const dampening = 0.1;

//     double edgeness = 0;
//     int a = _numberOfWavePoints - 3;
//     const double _edgeMultiplier = 0.07;

//     for (int i = 1; i < _numberOfWavePoints - 1; i++) {
//       edgeness = (((2 * i - (2 + a)).toDouble()) / a.toDouble()).abs();

//       velocityMap[i] += acceleration *
//           timeInterval *
//           (((heightMap[i - 1] + heightMap[i + 1]) / 2.0) - heightMap[i]);
//       velocityMap[i] *= pow(dampening * (1 + _edgeMultiplier * edgeness),
//           timeInterval * acceleration);
//     }

//     double maxHeight = 0.0;

//     for (int i = 1; i < _numberOfWavePoints - 1; i++) {
//       heightMap[i] += speed * timeInterval * velocityMap[i];
//       maxHeight = max(maxHeight, heightMap[i].abs());
//     }

//     if (maxHeight > 1.0) {
//       for (int i = 0; i < _numberOfWavePoints; i++) {
//         heightMap[i] = heightMap[i] / maxHeight;
//       }
//     }
//   }

//   void disturb(double velocity, double point) {
//     int index = (point * (_numberOfWavePoints - 3)).toInt() + 1;
//     velocityMap[index] += velocity;
//   }

//   double maxVelocity() {
//     return velocityMap.map((element) => element.abs()).reduce(max);
//   }
// }

// class LiquidAnimationState extends State<LiquidAnimation> {
//   LiquidAnimationMap _animationMap = LiquidAnimationMap(
//     heightMap: List.filled(_numberOfWavePoints, 0),
//     velocityMap: List.filled(_numberOfWavePoints, 0),
//   );

//   DateTime _lastTimestamp = DateTime.now();
//   late Timer _timer;

//   double _acceleration = 0;
//   final _velocityFactor = 15.0;

//   @override
//   void initState() {
//     _timer = Timer.periodic(const Duration(milliseconds: 16), ((Timer timer) {
//       var now = DateTime.now();
//       var interval =
//           (now.millisecondsSinceEpoch - _lastTimestamp.millisecondsSinceEpoch)
//                   .toDouble() /
//               1000;

//       var velocity = (_acceleration * interval * _velocityFactor).abs();
//       var disturbancePoint = _acceleration > 0 ? 0 : 1;

//       setState(() {
//         _animationMap.disturb(velocity, disturbancePoint.toDouble());
//         _animationMap.updateMaps(interval);
//         _lastTimestamp = now;
//       });
//     }));
//     accelerometerEvents.listen((AccelerometerEvent event) {
//       const GRAVITY = 9.8;
//       _acceleration = -event.x / GRAVITY;
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Transform(
//       transform: Matrix4.identity().scaled(2.0, 1, 1),
//       child: CustomPaint(
//         painter: LiquidPainter(map: _animationMap),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
// }

// class LiquidPainter extends CustomPainter {
//   LiquidPainter({required this.map});
//   final LiquidAnimationMap map;
//   final _waveHeight = 170.0;

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint();
//     var surfacePath = _path(size);

//     paint.color = const Color.fromARGB(255, 37, 124, 245);
//     var bodyPath = surfacePath;
//     bodyPath.lineTo(size.width, size.height);
//     bodyPath.lineTo(0, size.height);
//     bodyPath.close();

//     canvas.drawPath(bodyPath, paint);

//     paint.color = Colors.blue;
//     paint.strokeWidth = 2.0;
//     paint.style = PaintingStyle.stroke;

//     canvas.drawPath(surfacePath, paint);
//   }

//   Path _path(Size size) {
//     double pointDistance = size.width / (_numberOfWavePoints - 3);

//     Path path = Path();
//     Point<double> _cp = Point(-pointDistance, _yValue(map.heightMap[0]));

//     path.moveTo(_cp.x, _cp.y);

//     double edgeness = 0;
//     int a = _numberOfWavePoints - 3;
//     const double edgeMultiplier = 0.5;

//     for (int x = 1; x < _numberOfWavePoints; x++) {
//       edgeness = (((2 * x - (2 + a)).toDouble()) / a.toDouble()).abs();

//       double y = _yValue(map.heightMap[x] * (1 + edgeMultiplier * edgeness));

//       Point<double> next = Point(_cp.x + pointDistance, y);
//       Point<double> cp1 = Point(_cp.x + pointDistance * 0.5, _cp.y);
//       Point<double> cp2 = Point(_cp.x + pointDistance * 0.5, y);

//       path.cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, next.x, next.y);
//       _cp = next;
//     }

//     return path;
//   }

//   double _yValue(double height) {
//     return (1 - min(height, 1)) * _waveHeight;
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }

// class SkeletonLoader extends StatelessWidget {
//   final Widget child;

//   SkeletonLoader({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey,
//       highlightColor: Colors.green,
//       child: child,
//     );
//   }
// }
