import 'package:hive/hive.dart';
import 'package:water_reminder/local_database/water_item.dart';

class WaterService {
  final String _boxName = 'water_box';

  Future<Box<WaterItem>> get _box async =>
      await Hive.openBox<WaterItem>(_boxName);

  Future<void> addItem(WaterItem waterItem) async {
    var box = await _box;
    await box.add(waterItem);
  }

  Future<List<WaterItem>> getAllItems() async {
    var box = await _box;
    return box.values.toList();
  }

  Future<void> deleteItem(int index) async {
    var box = await _box;
    box.deleteAt(index);
  }
}
