import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musitayvr/data/models/track_model.dart';

class HiveDatabase {
  static const String _boxName = 'tracks';
  static const String _settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await Hive.openBox(_settingsBox);
  }

  static Box get _box => Hive.box(_boxName);
  static Box get _settings => Hive.box(_settingsBox);

  static Future<void> saveTrack(TrackModel track) async {
    await _box.put(track.id, jsonEncode(track.toJson()));
  }

  static Future<void> deleteTrack(String id) async {
    await _box.delete(id);
  }

  static List<TrackModel> getAllTracks() {
    final tracks = <TrackModel>[];
    for (final key in _box.keys) {
      final data = _box.get(key);
      if (data != null) {
        tracks.add(TrackModel.fromJson(jsonDecode(data)));
      }
    }
    tracks.sort((a, b) {
      if (a.addedDate == null && b.addedDate == null) return 0;
      if (a.addedDate == null) return 1;
      if (b.addedDate == null) return -1;
      return b.addedDate!.compareTo(a.addedDate!);
    });
    return tracks;
  }

  static bool isTrackDownloaded(String id) {
    return _box.containsKey(id);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }

  static bool get darkMode {
    return _settings.get('darkMode', defaultValue: true);
  }

  static Future<void> setDarkMode(bool value) async {
    await _settings.put('darkMode', value);
  }

  static bool get audioQualityHigh {
    return _settings.get('audioQualityHigh', defaultValue: true);
  }

  static Future<void> setAudioQualityHigh(bool value) async {
    await _settings.put('audioQualityHigh', value);
  }
}
