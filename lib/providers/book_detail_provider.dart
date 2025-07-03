import 'package:flutter/material.dart';

/// Provider per gestire lo stato della pagina di dettaglio del libro
class BookDetailProvider extends ChangeNotifier {
  int _selectedFormatIndex = 0;
  bool _isExpanded = false;

  int get selectedFormatIndex => _selectedFormatIndex;
  bool get isExpanded => _isExpanded;

  void selectFormat(int index) {
    _selectedFormatIndex = index;
    notifyListeners();
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}
