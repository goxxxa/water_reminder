import 'dart:math';

import 'package:flutter/material.dart';
import 'package:water_reminder/data/datasourses/firebase/firebase_service.dart';

class ChangeWaterTarget extends StatefulWidget {
  final int currentWaterTarget;
  const ChangeWaterTarget({super.key, required this.currentWaterTarget});

  @override
  State<ChangeWaterTarget> createState() => _ChangeWaterTargetState();
}

class _ChangeWaterTargetState extends State<ChangeWaterTarget> {
  ScrollController? _scrollController;
  final FirebaseService _databaseService = FirebaseService();
  late int _highlightedIndex;
  bool isMoving = false;
  bool isAnimating = false;

  final List<int> waterContainers =
      List.generate(200, (index) => (index + 1) * 50);
  static const double waterContainerHeight = 50;
  static const double waterContainersBuilderHeight = waterContainerHeight * 3;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController?.addListener(_onScroll);
    _highlightedIndex = widget.currentWaterTarget ~/ 50;

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollController!.jumpTo((_highlightedIndex - 2) * 50));
    super.initState();
  }

  void _onScroll() {
    final offset = _scrollController!.offset;
    final centerX = offset + waterContainersBuilderHeight / 2;

    for (int i = 0; i < waterContainers.length; ++i) {
      if (i * waterContainerHeight < centerX &&
          (i + 1) * waterContainerHeight > centerX) {
        if (!isAnimating) {
          setState(() {
            _highlightedIndex = i;
          });
        }

        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установить норму'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
        child: Column(
          children: [
            const Center(
              child: Text(
                  'Установите запланированное значение количества воды в день, чтобы оставаться активным и здоровым.'),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: waterContainersBuilderHeight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Stack(
                children: [
                  NotificationListener(
                    onNotification: (ScrollNotification notification) {
                      setState(() {
                        isMoving = notification is ScrollStartNotification ||
                            notification is ScrollEndNotification;
                      });
                      if (notification is ScrollEndNotification &&
                          !isAnimating) {
                        isAnimating = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            _scrollController!
                                .animateTo((_highlightedIndex - 1) * 50,
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.linear)
                                .then((_) => isAnimating = false));
                      }
                      return true;
                    },
                    child: ListView.builder(
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
                        .updateWaterTarget((_highlightedIndex + 1) * 50)
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
