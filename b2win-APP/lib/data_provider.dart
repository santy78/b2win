import 'package:flutter/material.dart';

class DataProvider with ChangeNotifier {
  String _storedValue = "";
  List<Map<String, dynamic>> _storedList = [];

  String get storedValue => _storedValue;
  List<Map<String, dynamic>> get storedList => _storedList;

  void updateValue(String newValue) {
    _storedValue = newValue;
    notifyListeners(); // UI updates automatically
  }

  void updateList(List<Map<String, dynamic>> newList) {
    _storedList = newList;
    notifyListeners();
  }
}
