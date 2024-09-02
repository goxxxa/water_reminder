// ignore: unused_import
import 'package:water_reminder/firebase/realtime_database.dart';

class TimeChartData{
  String startTime;
  String endTime;
  String water;

   @override
  String toString() {
    return '{Start Time: $startTime, End Time: $endTime, Water: $water}';
  }

  TimeChartData({
    required this.startTime,
    required this.endTime,
    required this.water
  });
}