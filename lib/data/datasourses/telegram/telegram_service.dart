//import 'package:flutter_telegram_web_app/flutter_telegram_web_app.dart' as tg;

class TelegramService {
  late int _userId;
  late String _userName;

  TelegramService._();
  static final TelegramService instance = TelegramService._();

  Future<void> initializeApp() async {
    // _userId = tg.initDataUnsafe.user!.id;
    // _userName = tg.initDataUnsafe.user!.username;

    // await tg.expand();
  }

  // int get userId => _userId;
  // String get userName => _userName;

  int get userId => 12345;
  String get userName => 'goxa';
}
