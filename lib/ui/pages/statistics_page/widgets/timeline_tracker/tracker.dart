import 'package:flutter/material.dart';
import 'package:water_reminder/utils/convert_minutes2hours.dart';
import 'package:water_reminder/utils/string_formater.dart';

import '../../../../../data/datasourses/firebase/firebase_service.dart';
import '../../../../../data/models/time_chart_data.dart';
import 'timeline.dart';

class TimeLineChart extends StatefulWidget {
  final double width;
  const TimeLineChart({required this.width, super.key});

  @override
  State<TimeLineChart> createState() => _TimeLineChartState();
}

class _TimeLineChartState extends State<TimeLineChart> {
  static const Duration duration = Duration(seconds: 0);

  late double globalPosition;
  late double localPosition;
  late double widgetWidth;

  final double informationContainerWidth = 150;
  final double informationContainerHeight = 30;
  static double informationContainerPosition = 0;
  final double informationContainerOverflow = 20;
  bool showInformationContainer = false;
  String informationContainerText = '';

  double dataPointerPosition = -50;

  double chartColumnHeight = 4;
  double chartDividerHeight = 3;

  final FirebaseService _databaseService = FirebaseService();

  List<TimeChartData> _chartData = [];

  static Offset infoContainerPosition = Offset.zero;
  static Size size = Size.zero;
  final GlobalKey _progressBarKey = GlobalKey();

  @override
  void initState() {
    widgetWidth = widget.width;

    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    final data = await _databaseService.getListOfWaterContainers();
    setState(() {
      for (int i = 0; i < 48; i++) {
        _chartData.add(TimeChartData(
            startTime: (30 * i).toHours(),
            endTime: (30 * (i + 1)).toHours(),
            water: '10'));
        for (int j = 0; j < data.length; j++) {
          if (int.parse(_chartData[i].startTime.toMinutes()) >=
                  int.parse(data[j].time.toMinutes()) &&
              int.parse(data[j].time.toMinutes()) <
                  int.parse(_chartData[i].endTime.toMinutes())) {
            _chartData[i].water = data[j].size;
            data.removeAt(j);
            break;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(children: [
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
              DataPointer(
                  position: dataPointerPosition,
                  show: showInformationContainer,
                  informationContainerHeight: informationContainerHeight,
                  size: Size(widget.width, 100)),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
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
                            dataPointerPosition = (localPosition ~/ 7) * 7 + 4;
                          });

                          if (localPosition <
                              (informationContainerWidth / 2 -
                                  informationContainerOverflow)) {
                            setState(() {
                              informationContainerPosition = globalPosition -
                                  localPosition.abs() -
                                  informationContainerOverflow;

                              informationContainerText = 'hui';
                              showInformationContainer = true;
                            });
                          } else if (localPosition >
                              (widget.width +
                                  informationContainerOverflow -
                                  (informationContainerWidth / 2))) {
                            setState(() {
                              informationContainerPosition = widgetWidth +
                                  informationContainerOverflow -
                                  informationContainerWidth +
                                  (globalPosition - localPosition.abs());
                              informationContainerText = '2';
                              showInformationContainer = true;
                            });
                          } else {
                            setState(() {
                              informationContainerPosition = globalPosition -
                                  informationContainerWidth / 2;
                              informationContainerText = 'chlen';
                              showInformationContainer = true;
                            });
                          }
                        },
                        onPanUpdate: (DragUpdateDetails details) {
                          globalPosition = details.globalPosition.dx;
                          localPosition = details.localPosition.dx;

                          setState(() {
                            informationContainerText =
                                infoContainerPosition.dx.toString();
                            //dataPointerPosition = (localPosition ~/ 7) * 7 - 7;
                            informationContainerPosition =
                                ((globalPosition ~/ 7) * 7) -
                                    informationContainerWidth / 2;
                          });

                          setState(() {
                            if (localPosition >=
                                    (informationContainerWidth / 2 -
                                        informationContainerOverflow) &&
                                localPosition <=
                                    (widget.width +
                                        informationContainerOverflow -
                                        (informationContainerWidth / 2))) {
                              informationContainerText =
                                  infoContainerPosition.dy.toString();

                              //showInformationContainer = true;
                            }
                          });
                          //debugPrint('$dataPointerPosition dataPointerPosition');
                          // debugPrint(
                          //     '$dataPointerPosition $globalPosition $localPosition');
                        },
                        onPanEnd: (details) {
                          setState(() {
                            showInformationContainer = false;
                          });
                        },
                        child: Stack(
                          children: [
                            FutureBuilder(
                                future: _fetchChartData(),
                                builder: (context, snapshot) {
                                  //debugPrint('${_chartData.toString()} hhhuuuui');
                                  return ListView.separated(
                                      itemCount: snapshot.hasData
                                          ? _chartData.length
                                          : 10,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, int index) {
                                        return VerticalDivider(
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
                                              height: snapshot.hasData
                                                  ? double.parse(
                                                      _chartData[index].water)
                                                  : 0,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .tertiary,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20.0),
                                                          topRight:
                                                              Radius.circular(
                                                                  20.0))),
                                            ),
                                          ],
                                        );
                                      });
                                }),
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
      ]),
      const SizedBox(
        height: 1,
      ),
      TimeLine(
        size: Size(widget.width, 50),
      ),
    ]);
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

  final double width = 15;
  final double height = 8;

  TrianglePainter(
      {required this.informationContainerHeight,
      required this.position,
      required this.show});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = show ? Colors.red : Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(Offset(position, informationContainerHeight),
        Offset(position, size.height), paint);

    final path = Path();
    path.moveTo(position + 40, informationContainerHeight);
    path.lineTo(position + 50, informationContainerHeight + 20);
    path.lineTo(position + 60, informationContainerHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) => false;
}



// final path = Path();
    // path.moveTo(position + 40, informationContainerHeight);
    // path.lineTo(position + 50,
    //     informationContainerHeight - 10); // move to the top vertex
    // path.addArc(
    //   Rect.fromCircle(
    //     center: Offset(position + 50, informationContainerHeight - 10),
    //     radius: 5, // adjust the radius to change the corner curvature
    //   ),
    //   pi, // start angle
    //   pi, // sweep angle
    // );
    // path.lineTo(position + 60, informationContainerHeight);
    // path.close();

    // canvas.drawPath(path, paint);

    //     final trianglePath = Path();
    // trianglePath.moveTo(position + 40, informationContainerHeight);
    // trianglePath.lineTo(position + 50, informationContainerHeight + 20);
    // trianglePath.lineTo(position + 60, informationContainerHeight);
    // trianglePath.close();

    // final roundedRectPath = Path();
    // roundedRectPath.addRRect(
    //   RRect.fromRectAndRadius(
    //     Rect.fromPoints(
    //       Offset(position + 40, informationContainerHeight),
    //       Offset(position + 60, informationContainerHeight + 20),
    //     ),
    //     Radius.circular(5), // adjust the radius to change the corner curvature
    //   ),
    // );

    // final combinedPath = Path();
    // combinedPath.addPath(trianglePath, Offset.zero);
    // combinedPath.addPath(roundedRectPath, Offset.zero);
    // combinedPath.fillType = PathFillType.evenOdd;

    // canvas.drawPath(combinedPath, paint);