import 'package:water_reminder/data/models/main_chart_data.dart';

import 'package:flutter/material.dart';

import '../../../../../data/datasourses/firebase/firebase_service.dart';
import '../../../../../data/models/visible_items_data.dart';

class MainChart extends StatefulWidget {
  final ValueNotifier? valueNotifier;
  const MainChart({super.key, required this.valueNotifier});

  @override
  State<MainChart> createState() => _MainChartState();
}

class _MainChartState extends State<MainChart> {
  static const Duration duration = Duration(seconds: 2);

  //List<MainChartData> mainChartItemsList = [];
  List test = [];
  List<VisibleItemsData> visibleItems = [];

  bool isMoving = false;
  bool isAnimating = false;

  int shift = 30; //30

  final ScrollController scrollController = ScrollController();
  final FirebaseService _databaseService = FirebaseService();

  double? dx;
  double chartItemWidth = 30; //30
  double chartDividerWidth = 7;

  double chartPickerWidth = 35;

  late double chartBlocWidth = (chartDividerWidth * 2 + chartItemWidth);

  int chartOffset = 50; //75
  late double widgetWidth;

  double taretLabelPosition = 1000 / (3000 / 200);

  void updatePickerPosition(double currentPickerPosition) {
    getChartItemsPositions(scrollController.offset);
    for (final item in visibleItems) {
      if ((widgetWidth - currentPickerPosition) >= item.startX &&
          item.endX >= (widgetWidth - currentPickerPosition)) {
        debugPrint(
            '$currentPickerPosition ${widgetWidth - ((item.endX + item.startX) / 2.0)}');
        setState(() {
          dx = widgetWidth - ((item.endX + item.startX) / 2.0);
        });
        break;
      }
    }
  }

  void getChartItemsPositions(double scrollOffset) {
    visibleItems.clear();
    int firstVisibleIndex =
        (scrollOffset + (scrollOffset % chartBlocWidth)) ~/ chartBlocWidth;
    bool flag = true;
    int index = 0;
    while (flag) {
      visibleItems.add(VisibleItemsData(
          itemIndex: firstVisibleIndex == 0
              ? firstVisibleIndex + index
              : firstVisibleIndex + index,
          startX: 0,
          endX: 0));
      index++;
      if ((firstVisibleIndex + index) * chartBlocWidth >=
          widgetWidth + scrollOffset) {
        flag = false;
      }
    }
    for (int index = 0; index < visibleItems.length; index++) {
      if (index == 0) {
        visibleItems[index].startX =
            scrollController.offset % chartBlocWidth != 0
                ? scrollController.offset % chartBlocWidth * -1
                : 0;
        visibleItems[index].endX = visibleItems[index].startX + chartBlocWidth;
      } else {
        visibleItems[index].startX = visibleItems[index - 1].endX;
        visibleItems[index].endX = visibleItems[index].startX + chartBlocWidth;
      }
    }
  }

  void scrollChartToPicker() {
    isAnimating = true;
    late double offset;
    getChartItemsPositions(scrollController.offset);
    for (final item in visibleItems) {
      if ((widgetWidth - dx!) >= item.startX &&
          item.endX >= (widgetWidth - dx!)) {
        setState(() {
          offset = scrollController.offset -
              ((widgetWidth - dx!) - ((item.endX + item.startX) / 2));
        });
        break;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        scrollController
            .animateTo(offset,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear)
            .then(
              (value) => {
                isAnimating = false,
              },
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widgetWidth = MediaQuery.of(context).size.width - chartOffset;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 150,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: duration,
            width: widgetWidth,
            height: taretLabelPosition,
            child: Container(
              width: MediaQuery.of(context).size.width - 0,
              height: 2,
              decoration: const BoxDecoration(color: Colors.blue),
            ),
          ),
          Container(
              width: widgetWidth,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  if (dx != null)
                    AnimatedPositioned(
                      duration: const Duration(microseconds: 1000),
                      top: 40,
                      left: dx! - chartPickerWidth / 2,
                      child: Container(
                        width: chartPickerWidth,
                        height: 110,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Container(
                            height: 110,
                            width: 2,
                            decoration: const BoxDecoration(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      setState(() {
                        isMoving = notification is ScrollStartNotification ||
                            notification is ScrollEndNotification;
                      });
                      if (notification is ScrollEndNotification &&
                          !isAnimating) {
                        scrollChartToPicker();
                      }
                      return true;
                    },
                    child: FutureBuilder<List<MainChartData>>(
                      future: _databaseService.getDataForMainChart(),
                      builder: (context,
                          AsyncSnapshot<List<MainChartData>> asyncSnapshot) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: asyncSnapshot.hasData
                              ? asyncSnapshot.data!.length
                              : 0,
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTapUp: (details) {
                                updatePickerPosition(details.globalPosition.dx);

                                widget.valueNotifier!.value =
                                    asyncSnapshot.data![index].date;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      color: Colors.transparent,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AnimatedContainer(
                                          duration: duration,
                                          width: 25,
                                          height: double.parse(asyncSnapshot
                                                  .data![index].totalWater) /
                                              20,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                              child: Container(
                                            height: double.parse(asyncSnapshot
                                                .data![index].totalWater),
                                            width: 2,
                                            decoration: const BoxDecoration(
                                                color: Colors.red),
                                          )),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        // Text(mainChartItemsList[index].date)
                                        Text(index.toString().length == 1
                                            ? '0$index'
                                            : '$index')
                                      ],
                                    ),
                                    Container(
                                      width: 10,
                                      color: Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )),
          FutureBuilder(
              future: _databaseService.getWaterConsumption(),
              builder: (context, AsyncSnapshot snapshot) {
                return Align(
                  alignment: Alignment.topRight,
                  child: AnimatedContainer(
                    alignment: Alignment.bottomCenter,
                    duration: duration,
                    height: taretLabelPosition - 30.0,
                    width: chartOffset - 2,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(color: Colors.red)),
                    child:
                        Text(snapshot.hasData ? snapshot.data.toString() : '0'),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
