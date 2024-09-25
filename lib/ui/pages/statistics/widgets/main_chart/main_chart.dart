import 'package:intl/intl.dart';
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

  final double widgetHeight = 150;

  double dx = 419;
  double chartItemWidth = 40; //30
  double chartDividerWidth = 15;

  double chartPickerWidth = 55;

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
        debugPrint(dx.toString());
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
      if ((widgetWidth - dx) >= item.startX &&
          item.endX >= (widgetWidth - dx)) {
        setState(() {
          offset = scrollController.offset -
              ((widgetWidth - dx) - ((item.endX + item.startX) / 2));
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
      height: widgetHeight,
      child: Stack(
        children: [
          SizedBox(
            width: widgetWidth,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(microseconds: 1000),
                  top: 0,
                  left: dx - chartPickerWidth / 2,
                  child: Container(
                    width: chartPickerWidth,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    setState(() {
                      isMoving = notification is ScrollStartNotification ||
                          notification is ScrollEndNotification;
                    });
                    if (notification is ScrollEndNotification && !isAnimating) {
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
                          if (asyncSnapshot.hasData) {
                            asyncSnapshot.data!.sort((a, b) {
                              DateFormat formatter = DateFormat('dd_MM_yy');
                              DateTime dateA = formatter.parse(a.date);
                              DateTime dateB = formatter.parse(b.date);
                              return dateA.compareTo(dateB);
                            });
                          }
                          return GestureDetector(
                            onTapUp: (details) {
                              updatePickerPosition(details.globalPosition.dx);

                              widget.valueNotifier!.value =
                                  asyncSnapshot.data![index].date;
                            },
                            child: SizedBox(
                              child: Row(
                                children: [
                                  Container(
                                    width: chartDividerWidth,
                                    color: Colors.transparent,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration: duration,
                                        width: chartItemWidth,
                                        height: double.parse(asyncSnapshot
                                                .data![index].totalWater) /
                                            20,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                          '${asyncSnapshot.data![index].date.split('_')[0]}/${asyncSnapshot.data![index].date.split('_')[1]}')
                                    ],
                                  ),
                                  Container(
                                    width: chartDividerWidth,
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
            ),
          ),
        ],
      ),
    );
  }
}
