import 'package:flutter/material.dart';

class RestaurantProvider extends ChangeNotifier {
  String _name = '';
  String _description = '';
  String _location = '';
  bool _isActive = false;
  List<String> _foodTypes = [];

  // Getters
  String get name => _name;
  String get description => _description;
  String get location => _location;
  bool get isActive => _isActive;
  List<String> get foodTypes => _foodTypes;

  void updateRestaurant({
    required String name,
    required String description,
    required String location,
    required bool isActive,
    required List<String> foodTypes,
  }) {
    _name = name;
    _description = description;
    _location = location;
    _isActive = isActive;
    _foodTypes = foodTypes;
    notifyListeners();
  }
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateDescription(String description) {
    _description = description;
    notifyListeners();
  }

  void updateLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void updateIsActive(bool isActive) {
    _isActive = isActive;
    notifyListeners();
  }

  void updateFoodTypes(List<String> foodTypes) {
    _foodTypes = foodTypes;
    notifyListeners();
  }
}
