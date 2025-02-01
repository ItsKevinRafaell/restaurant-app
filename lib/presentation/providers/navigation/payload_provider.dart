import 'package:flutter/material.dart';

class PayloadProvider extends ChangeNotifier {
  String _payload = '';

  String get payload => _payload;

  void updatePayload(String payload) {
    _payload = payload;
    notifyListeners();
  }
}
