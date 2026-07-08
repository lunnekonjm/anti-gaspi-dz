import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DevProvider extends ChangeNotifier {
  static const _boxName = 'settings_box';
  static const _devModeKey = 'is_dev_mode';
  bool _isDevMode = false;
  String _devApiKey = 'antigaspi_secret_dev_key';

  bool get isDevMode => _isDevMode;
  String get devApiKey => _devApiKey;

  DevProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final box = Hive.box(_boxName);
    _isDevMode = box.get(_devModeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> toggleDevMode(bool value) async {
    _isDevMode = value;
    final box = Hive.box(_boxName);
    await box.put(_devModeKey, value);
    notifyListeners();
  }
}
