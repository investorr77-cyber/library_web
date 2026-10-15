import 'package:flutter/foundation.dart';

/// Имитация сети для репозиториев в памяти: задержка ответа
/// и переключатель «сервер недоступен» для проверки состояния ошибки.
class FakeNetwork extends ChangeNotifier {
  bool _failRequests = false;

  bool get failRequests => _failRequests;

  set failRequests(bool value) {
    _failRequests = value;
    notifyListeners();
  }

  /// Небольшая задержка: без неё индикатор загрузки невозможно увидеть.
  Future<void> roundTrip() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (_failRequests) {
      throw Exception('сервер не отвечает (имитация сбоя сети)');
    }
  }
}
