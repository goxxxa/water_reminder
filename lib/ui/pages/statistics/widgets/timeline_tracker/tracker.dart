import 'package:flutter/material.dart';
import 'package:water_reminder/utils/convert_minutes2hours.dart';
import 'package:water_reminder/utils/string_formater.dart';

import '../../../../../data/datasourses/firebase/firebase_service.dart';
import '../../../../../data/models/time_chart_data.dart';
import 'timeline.dart';

class TimeLineChart extends StatefulWidget {
  final ValueNotifier? valueController;
  final double width;
  const TimeLineChart({
    required this.width,
    super.key,
    required this.valueController,
  });

  @override
  State<TimeLineChart> createState() => _TimeLineChartState();
}

class _TimeLineChartState extends State<TimeLineChart> {
  static const Duration duration = Duration(seconds: 0);

  late double globalPosition;
  late double localPosition;
  late double widgetWidth;

  static const double informationContainerWidth = 150;
  static const double informationContainerHeight = 30;
  static const double informationContainerOverflow = 20;

  late double informationContainerPosition = 0;
  late bool showInformationContainer = false;
  late String informationContainerText = '';

  double dataPointerPosition = 0;

  static const double chartColumnHeight = 4;
  static const double chartDividerHeight = 3;

  final FirebaseService _databaseService = FirebaseService();

  final List<TimeChartData> _chartData = [];
  final GlobalKey _progressBarKey = GlobalKey();

  Future<void> _fetchChartData() async {
    final data = await _databaseService
        .getListOfWaterContainers(widget.valueController!.value);
    _chartData.clear();
    for (int i = 0; i < 48; i++) {
      setState(() {
        _chartData.add(TimeChartData(
            startTime: (30 * i).toHours(),
            endTime: (30 * (i + 1)).toHours(),
            water: '0'));
      });
      for (int j = 0; j < data.length; j++) {
        if (int.parse(_chartData[i].startTime.toMinutes()) >=
                int.parse(data[j].time.toMinutes()) &&
            int.parse(data[j].time.toMinutes()) <
                int.parse(_chartData[i].endTime.toMinutes())) {
          setState(() {
            _chartData[i].water = data[j].size;
          });
          data.removeAt(j);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            InformationContainer(
                key: _progressBarKey,
                width: informationContainerWidth,
                height: informationContainerHeight,
                position: informationContainerPosition,
                text: informationContainerText,
                show: showInformationContainer),
            Center(
              child: Stack(
                children: [
                  SizedBox(
                    height: 100,
                    width: widget.width,
                    child: Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onPanStart: (DragStartDetails details) {
                              globalPosition = details.globalPosition.dx;
                              localPosition = details.localPosition.dx;
                              setState(() {
                                showInformationContainer = true;
                                dataPointerPosition =
                                    (localPosition - localPosition % 7)
                                        .clamp(0, 334);
                                if (localPosition <
                                    informationContainerWidth / 2 -
                                        informationContainerOverflow) {
                                  informationContainerPosition =
                                      globalPosition -
                                          localPosition -
                                          informationContainerOverflow;
                                } else if (localPosition >
                                    widget.width -
                                        informationContainerWidth / 2 +
                                        informationContainerOverflow) {
                                  informationContainerPosition = widget.width -
                                      informationContainerWidth / 2 -
                                      (globalPosition - localPosition);
                                } else {
                                  informationContainerPosition = localPosition -
                                      informationContainerWidth / 2 +
                                      (globalPosition - localPosition);
                                }
                              });
                            },
                            onPanUpdate: (DragUpdateDetails details) {
                              globalPosition = details.globalPosition.dx;
                              localPosition = details.localPosition.dx;

                              setState(() {
                                dataPointerPosition =
                                    (localPosition - localPosition % 7)
                                        .clamp(0, 334);

                                if (localPosition <
                                    informationContainerWidth / 2 -
                                        informationContainerOverflow) {
                                  informationContainerPosition =
                                      globalPosition -
                                          localPosition -
                                          informationContainerOverflow;
                                } else if (localPosition >
                                    widget.width -
                                        informationContainerWidth / 2 +
                                        informationContainerOverflow) {
                                  informationContainerPosition = widget.width -
                                      informationContainerWidth / 2 -
                                      (globalPosition - localPosition);
                                } else {
                                  informationContainerPosition = localPosition -
                                      informationContainerWidth / 2 +
                                      (globalPosition - localPosition);
                                }
                                showInformationContainer = true;
                              });
                            },
                            onPanEnd: (details) {
                              setState(() {
                                showInformationContainer = false;
                              });
                            },
                            child: Stack(
                              children: [
                                DataPointer(
                                  position: dataPointerPosition,
                                  show: showInformationContainer,
                                  informationContainerHeight:
                                      informationContainerHeight,
                                  size: Size(widget.width, 100),
                                ),
                                FutureBuilder(
                                  future: _fetchChartData(),
                                  builder: (context, snapshot) {
                                    return ListView.separated(
                                      itemCount: _chartData.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, int index) {
                                        return const VerticalDivider(
                                          color: Colors.transparent,
                                          width: chartDividerHeight,
                                        );
                                      },
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, int index) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            AnimatedContainer(
                                              duration: duration,
                                              width: chartColumnHeight,
                                              height: double.parse(
                                                  _chartData[index].water),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(20.0),
                                                  topRight:
                                                      Radius.circular(20.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 1,
        ),
        TimeLine(
          size: Size(widget.width, 50),
        ),
      ],
    );
  }
}

class InformationContainer extends StatefulWidget {
  final double width;
  final double height;
  final double position;
  final String text;
  final bool show;

  const InformationContainer({
    required this.width,
    required this.height,
    required this.position,
    required this.text,
    required this.show,
    super.key,
  });

  @override
  State<InformationContainer> createState() => _InformationContainerState();
}

class _InformationContainerState extends State<InformationContainer> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: widget.width,
      height: widget.height,
      left: widget.position,
      child: Column(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.show
                  ? const Color.fromARGB(255, 3, 95, 171)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataPointer extends StatefulWidget {
  final double position;
  final double informationContainerHeight;
  final bool show;
  final Size size;
  const DataPointer(
      {required this.position,
      required this.size,
      required this.show,
      super.key,
      required this.informationContainerHeight});

  @override
  State<DataPointer> createState() => _DataPointerState();
}

class _DataPointerState extends State<DataPointer> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: TrianglePainter(
          show: widget.show,
          position: widget.position,
          informationContainerHeight: widget.informationContainerHeight),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final double position;
  final double informationContainerHeight;
  final bool show;

  final double width = 16;
  final double height = 8;

  TrianglePainter(
      {required this.informationContainerHeight,
      required this.position,
      required this.show});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          show ? const Color.fromARGB(255, 194, 194, 194) : Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(Offset(position, informationContainerHeight),
        Offset(position, size.height), paint);

    final path = Path();
    path.moveTo(position, informationContainerHeight + height);
    path.lineTo(position - width / 2, informationContainerHeight);
    path.lineTo(position + width / 2, informationContainerHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) => true;
}
