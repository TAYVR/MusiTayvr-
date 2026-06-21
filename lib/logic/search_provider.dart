import 'package:flutter/foundation.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/data/services/youtube_service.dart';

class SearchProvider extends ChangeNotifier {
  final YouTubeService _youtubeService = YouTubeService();
  List<TrackModel> _results = [];
  TrackModel? _selectedTrack;
  bool _isLoading = false;
  String? _error;
  String _query = '';

  List<TrackModel> get results => _results;
  TrackModel? get selectedTrack => _selectedTrack;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    _query = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _youtubeService.search(query);
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _results = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectTrack(TrackModel track) async {
    _isLoading = true;
    _selectedTrack = track;
    notifyListeners();

    try {
      final fullInfo = await _youtubeService.getTrackInfo(track.id);
      _selectedTrack = fullInfo;
    } catch (e) {
      _error = 'Failed to get track info: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _results = [];
    _selectedTrack = null;
    _query = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _youtubeService.dispose();
    super.dispose();
  }
}
