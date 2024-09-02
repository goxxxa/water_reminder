import 'package:hive/hive.dart';

import '../models/water_container_data.dart';
part 'water_item.g.dart';

@HiveType(typeId: 1)
class WaterItem {
  @HiveField(0)
  final String userName;

  @HiveField(1)
  final int goal;

  @HiveField(2)
  final int userWeight;

  @HiveField(3)
  final List<WaterContainer> data;

  WaterItem(this.userName, this.goal, this.userWeight, this.data);
}
