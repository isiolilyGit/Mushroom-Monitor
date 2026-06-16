import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../services/storage_service.dart';

class FarmProvider extends ChangeNotifier {
  List<Farm> _farms = [];
  bool _loaded = false;

  List<Farm> get farms => _farms;
  bool get isLoaded => _loaded;

  Future<void> loadFarms() async {
    _farms = await StorageService.loadFarms();
    _loaded = true;
    notifyListeners();
  }

  Farm? getFarmById(String id) {
    try {
      return _farms.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addFarm(Farm farm) async {
    _farms.add(farm);
    await StorageService.saveFarms(_farms);
    notifyListeners();
  }

  Future<void> deleteFarm(String id) async {
    _farms.removeWhere((f) => f.id == id);
    await StorageService.saveFarms(_farms);
    notifyListeners();
  }
}