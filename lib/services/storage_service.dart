import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm.dart';

class StorageService {
  static const String _farmsKey = 'farms';

  static Future<List<Farm>> loadFarms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_farmsKey);
    if (jsonString == null) return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((item) => Farm.fromJson(item)).toList();
  }

  static Future<void> saveFarms(List<Farm> farms) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(farms.map((f) => f.toJson()).toList());
    await prefs.setString(_farmsKey, jsonString);
  }
}