//import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart';
import 'package:flutter/scheduler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:water_reminder/models/main_chart_data.dart';
import 'package:xrandom/xrandom.dart';

import 'package:flutter/material.dart';

class MainChartTest extends StatefulWidget {
  const MainChartTest({super.key});

  @override
  State<MainChartTest> createState() => _MainChartTestState();
}

class VisibleItemsData {
  int itemIndex;
  double startX;
  double endX;

  VisibleItemsData(
      {required this.itemIndex, required this.startX, required this.endX});
}

class _MainChartTestState extends State<MainChartTest> {
  static const Duration duration = Duration(seconds: 2);
  List<MainChartData> mainChartItemsList = [];
  List test = [];
  List<VisibleItemsData> visibleItems = [];

  bool isMoving = false;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollController scrollController = ScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  double dx = 0;

  void scrollChart() {
    //debugPrint('start void scrolling');
    //debugPrint('${300 - dx}');
    for (final item in itemPositionsListener.itemPositions.value) {
      //debugPrint(
      //    'item index:${item.index} start:${item.itemLeadingEdge * 300} end:${item.itemTrailingEdge * 300}');
      if ((300 - dx) >= (item.itemLeadingEdge * 300) &&
          (item.itemTrailingEdge * 300) >= (300 - dx)) {
        //debugPrint('success');
        scroll(300 - dx);
      }
    }
  }

  void scroll(double delta) {
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   debugPrint('attach');
    //   scrollOffsetController
    //       .animateScroll(offset: delta, duration: duration)
    //       .then((value) => debugPrint('animation cancel'));
    // });
  }

  void _listener() {
    itemPositionsListener.itemPositions.addListener(() {
      visibleItems.clear();
      for (final item in itemPositionsListener.itemPositions.value) {
        visibleItems.add(VisibleItemsData(
            itemIndex: item.index,
            startX: item.itemLeadingEdge * 300,
            endX: item.itemTrailingEdge * 300));
      }
    });
  }

  @override
  void initState() {
    debugPrint('huuuuuuui');
    for (int i = 0; i < 20; i++) {
      final random = Xrandom();
      mainChartItemsList.add(MainChartData(
          date: random.nextInt(30).toString(),
          totalWater: random.nextInt(100).toString()));
    }
    _listener();
    //scrollChart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
      onTapDown: (details) {
        setState(() {
          for (final item in visibleItems) {
            if ((300 - details.localPosition.dx) >= item.startX &&
                item.endX >= (300 - details.localPosition.dx)) {
              dx = 300 - (item.endX + item.startX) / 2;
              break;
            }
          }
        });
      },
      child: Listener(
        onPointerMove: (event) {
          debugPrint('${event.delta.distance} ${event.delta.dx}');
          if (event.delta.dx != 0) {
            isMoving = true;
            //debugPrint('scrolling');
          }
        },
        onPointerUp: (event) {
          if (isMoving) {
            isMoving = false;
            //debugPrint('end');

            scrollChart();
          }
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(microseconds: 0),
              top: 50,
              left: dx - 10,
              child: Container(
                width: 20,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            ScrollablePositionedList.builder(
              itemCount: 20,
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemBuilder: (context, int index) {
                return Container(
                  child: Row(
                    children: [
                      const VerticalDivider(
                        color: Colors.transparent,
                        thickness: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: duration,
                            width: 10,
                            height: double.parse(
                                mainChartItemsList[index].totalWater),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(mainChartItemsList[index].date)
                        ],
                      ),
                      const VerticalDivider(
                        color: Colors.transparent,
                        thickness: 15,
                      ),
                    ],
                  ),
                );
              },
              scrollOffsetListener: scrollOffsetListener,
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
            ),
            // const Center(
            //   child: Divider(
            //     color: Colors.black,
            //     thickness: 5,
            //   ),
            // ),
            // const Align(
            //   alignment: Alignment.topCenter,
            //   child: Divider(
            //     thickness: 2,
            //     color: Colors.black,
            //   ),
            // ),
            // const Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Divider(
            //     color: Colors.black,
            //     thickness: 5,
            //   ),
            // ),
          ],
        ),
      ),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
