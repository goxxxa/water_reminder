import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart' as tg;

class TelegramService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String? name = tg.initDataUnsafe.user?.first_name;
  int id = tg.initDataUnsafe.user!.id;
  String? photo = tg.initDataUnsafe.user?.photo_url;

  String? get userName => name;
  int get userTelegramId => id;
  String? get userPhoto => photo;

  TelegramService() {
    tg.expand();
  }
}
