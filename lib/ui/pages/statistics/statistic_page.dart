import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:water_reminder/ui/pages/statistics/widgets/timeline_tracker/tracker.dart';

import '../../../data/datasourses/firebase/firebase_service.dart';
import 'widgets/progress_bar/progress_bar.dart';
import 'widgets/main_chart/main_chart.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  FirebaseService? _databaseService;

  ConfettiController? _confettiController;
  final ValueNotifier<String> _valueNotifier = ValueNotifier('');

  static Offset confettiWidgetPosition = Offset.zero;
  static Size size = Size.zero;
  final GlobalKey _progressBarKey = GlobalKey();

  @override
  void initState() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _databaseService = FirebaseService();

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => calculateConfettiPlayPosition());
  }

  void calculateConfettiPlayPosition() {
    final RenderBox box =
        _progressBarKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      confettiWidgetPosition = box.localToGlobal(Offset.zero);
      size = box.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Статистика',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                MainChart(
                  valueNotifier: _valueNotifier,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: FutureBuilder(
                          future: _databaseService!.getWaterConsumption(),
                          builder: (context, AsyncSnapshot snapshot) {
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 16.0,
                                ),
                                Countup(
                                  begin: 0,
                                  key: _progressBarKey,
                                  end: snapshot.hasData
                                      ? double.parse(snapshot.data!.toString())
                                      : 0.0,
                                  duration: const Duration(milliseconds: 2000),
                                  suffix: ' ml',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500),
                                ),
                                StreamBuilder(
                                  stream:
                                      _databaseService!.userWaterTargetStream,
                                  builder: (context, streamSnapshot) {
                                    return ProgressBar(
                                      target: streamSnapshot.hasData
                                          ? int.parse(
                                              streamSnapshot.data!.toString())
                                          : 0,
                                      currentWaterLevel:
                                          snapshot.hasData ? snapshot.data! : 0,
                                      confettiController: _confettiController!,
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, top: 10.0),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'Детализация по времени суток',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            TimeLineChart(
                              valueController: _valueNotifier,
                              width: 336,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: confettiWidgetPosition.dx + (size.width / 2),
              top: confettiWidgetPosition.dy - (size.height / 2),
              child: ConfettiWidget(
                confettiController: _confettiController!,
                blastDirection: pi / 2,
                numberOfParticles: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }
}
