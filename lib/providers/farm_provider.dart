import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../services/storage_service.dart';

class FarmProvider extends ChangeNotifier {
  List<Farm> _farms = [];

  List<Farm> get farms => _farms;

  Future<void> loadFarms() async {
    _farms = await StorageService.loadFarms();
    notifyListeners();
  }

  Future<void> addFarm(Farm farm) async {
    _farms.add(farm);
    await StorageService.saveFarms(_farms);
    notifyListeners();
  }

  Future<void> deleteFarm(int index) async {
    _farms.removeAt(index);
    await StorageService.saveFarms(_farms);
    notifyListeners();
  }

  // You could add updateFarm later if needed
}