import 'package:flutter/material.dart';

class RestaurantProvider extends ChangeNotifier {
  int? _id;
  String _name = '';
  String _description = '';
  bool _isActive = false;
  List<String> _foodTypes = [];
  String _cep = '';
  String _logradouro = '';
  String _numero = '';
  String _complemento = '';
  String _bairro = '';
  String _cidade = '';
  String _uf = '';

  int? get id => _id;
  String get name => _name;
  String get description => _description;
  bool get isActive => _isActive;
  List<String> get foodTypes => _foodTypes;
  String get cep => _cep;
  String get logradouro => _logradouro;
  String get numero => _numero;
  String get complemento => _complemento;
  String get bairro => _bairro;
  String get cidade => _cidade;
  String get uf => _uf;

  void updateRestaurant({
    required int id,
    required String name,
    required String description,
    required bool isActive,
    required List<dynamic> foodTypes,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
  }) {
    _id = id;
    _name = name;
    _description = description;
    _isActive = isActive;
    _foodTypes = foodTypes.map((e) => e.toString()).toList();
    _cep = cep ?? '';
    _logradouro = logradouro ?? '';
    _numero = numero ?? '';
    _complemento = complemento ?? '';
    _bairro = bairro ?? '';
    _cidade = cidade ?? '';
    _uf = uf ?? '';
    notifyListeners();
  }

  void updateId(int id) {
    _id = id;
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

  void updateIsActive(bool isActive) {
    _isActive = isActive;
    notifyListeners();
  }

  void updateFoodTypes(List<String> foodTypes) {
    _foodTypes = foodTypes;
    notifyListeners();
  }

  void updateCep(String cep) {
    _cep = cep.replaceAll('-', '').replaceAll(RegExp(r'[^0-9]'), '');
    notifyListeners();
  }

  void updateLogradouro(String logradouro) {
    _logradouro = logradouro;
    notifyListeners();
  }

  void updateNumero(String numero) {
    _numero = numero;
    notifyListeners();
  }

  void updateComplemento(String complemento) {
    _complemento = complemento;
    notifyListeners();
  }

  void updateBairro(String bairro) {
    _bairro = bairro;
    notifyListeners();
  }

  void updateCidade(String cidade) {
    _cidade = cidade;
    notifyListeners();
  }

  void updateEstado(String uf) {
    _uf = uf;
    notifyListeners();
  }

  void clearRestaurant() {
    _id = null;
    _name = '';
    _description = '';
    _isActive = false;
    _foodTypes = [];
    _cep = '';
    _logradouro = '';
    _numero = '';
    _complemento = '';
    _bairro = '';
    _cidade = '';
    _uf = '';
    notifyListeners();
  }

  void resetRestaurant() {
    _id = null;
    _name = '';
    _description = '';
    _isActive = false;
    _foodTypes = [];
    _cep = '';
    _logradouro = '';
    _numero = '';
    _complemento = '';
    _bairro = '';
    _cidade = '';
    _uf = '';
    notifyListeners();
  }
}
