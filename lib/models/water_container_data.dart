import 'package:intl/intl.dart';

class WaterContainer {
  String size;
  String date;
  String time;

  factory WaterContainer.fromMap(Map<String, dynamic> map) {
    return WaterContainer(
        size: map['size'], date: map['date'], time: map['time']);
  }

  @override
  String toString() {
    return '(size: $size, date: $date, time: $time)';
  }

  Map<String, dynamic> toDB() {
    return {time: size};
  }

  bool operator >(WaterContainer other) {
    DateTime thisTime = DateFormat('dd/MM/yy HH:mm')
        .parse('${date.replaceAll('_', '/')} $time');
    DateTime otherTime = DateFormat('dd/MM/yy HH:mm')
        .parse('${other.date.replaceAll('_', '/')} ${other.time}');
    return thisTime.compareTo(otherTime) > 0;
  }

  WaterContainer({required this.size, required this.date, required this.time});
}
