import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:water_reminder/data/models/main_chart_data.dart';
import 'package:xrandom/xrandom.dart';

import 'package:flutter/material.dart';

import '../../../../data/datasourses/firebase/firebase_service.dart';

class MainChart extends StatefulWidget {
  const MainChart({super.key});

  @override
  State<MainChart> createState() => _MainChartState();
}

class _MainChartState extends State<MainChart> {
  static const Duration duration = Duration(seconds: 2);
  List<MainChartData> mainChartItemsList = [];
  List test = [];

  final FirebaseService _databaseService = FirebaseService();

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void _listener() async {
    var uui = await _databaseService.getDataForMainChart();
    debugPrint('huuuuuuuuuuuuuuuuuuuuuuui');
    debugPrint(uui.toString());

    itemPositionsListener.itemPositions.addListener(() {
      for (final item in itemPositionsListener.itemPositions.value) {
        test.add(item);
      }
      debugPrint(itemPositionsListener.itemPositions.value.first.toString());
      for (final item in itemPositionsListener.itemPositions.value) {
        debugPrint('${item.index} ${item.itemLeadingEdge * 300} ${300 - dx}');
      }
    });
  }

  double dx = 50;

  void testData() {
    var test = _databaseService.getDataForMainChart();
    debugPrint('huuuuuuuuuuuuuuuuuuuuuuui');
    debugPrint(test.toString());
  }

  @override
  void initState() async {
    for (int i = 0; i < 10; i++) {
      final random = Xrandom();
      mainChartItemsList.add(MainChartData(
          date: random.nextInt(30).toString(),
          totalWater: random.nextInt(100).toString()));
    }
    _listener();
    super.initState();

    testData();
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GestureDetector(
              onTapDown: (TapDownDetails details) {
      setState(() {
        dx = details.localPosition.dx;
      });
              },
              child: Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(microseconds: 0),
          top: 50,
          left: dx,
          child: Container(
            width: 20,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        ScrollablePositionedList.separated(
          itemCount: 10,
          //physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, int index) {
            return const VerticalDivider(
              color: Colors.transparent,
              width: 20,
            );
          },
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemBuilder: (context, int index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: duration,
                  width: 10,
                  height:
                      double.parse(mainChartItemsList[index].totalWater),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(mainChartItemsList[index].date)
              ],
            );
          },
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
    );
  }
}
