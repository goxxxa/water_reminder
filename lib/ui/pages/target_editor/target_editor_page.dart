import 'package:flutter/material.dart';

class ChangeWaterTarget extends StatefulWidget {
  final int currentWaterTarget;
  const ChangeWaterTarget({super.key, required this.currentWaterTarget});

  @override
  State<ChangeWaterTarget> createState() => _ChangeWaterTargetState();
}

class _ChangeWaterTargetState extends State<ChangeWaterTarget> {
  ScrollController? _scrollController;
  late final int _highlightedIndex = 1;

  final List<int> waterContainers =
      List.generate(200, (index) => (index + 1) * 50);
  static const double waterContainerHeight = 50;
  static const double waterContainersBuilderHeight = waterContainerHeight * 3;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установить норму'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: waterContainersBuilderHeight,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              itemCount: waterContainers.length,
              itemBuilder: (context, int index) {
                return Container(
                  height: waterContainerHeight,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.white)),
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
    );
  }
}
