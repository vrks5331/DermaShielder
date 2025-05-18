import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isDarkMode = false;
  int counter = 0;

  void toggleDarkMode (context) {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void incrementCounter() {
    counter++;
    notifyListeners();
  }
}