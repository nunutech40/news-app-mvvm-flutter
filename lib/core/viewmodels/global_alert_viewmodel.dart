import 'package:flutter/foundation.dart';

class GlobalAlertViewModel extends ChangeNotifier {
  bool _hasNetworkError = false;
  bool _isTimeout = false;
  DateTime? _timestamp;

  bool get hasNetworkError => _hasNetworkError;
  bool get isTimeout => _isTimeout;
  DateTime? get timestamp => _timestamp;

  void showNetworkError({required bool isTimeout}) {
    _hasNetworkError = true;
    _isTimeout = isTimeout;
    _timestamp = DateTime.now();
    notifyListeners();
  }

  void clearNetworkError() {
    _hasNetworkError = false;
    notifyListeners();
  }
}
