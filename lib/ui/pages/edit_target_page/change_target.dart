import 'package:flutter/material.dart';

class ChangeWaterTarget extends StatefulWidget {
  const ChangeWaterTarget({super.key});

  @override
  State<ChangeWaterTarget> createState() => _ChangeWaterTargetState();
}

class _ChangeWaterTargetState extends State<ChangeWaterTarget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Установить норму')),
    );
  }
}