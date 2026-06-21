import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musitayvr/data/models/track_model.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  TrackModel? _currentTrack;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;
  List<TrackModel> _queue = [];
  int _currentIndex = -1;
  String? _error;

  TrackModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get isShuffled => _isShuffled;
  LoopMode get loopMode => _loopMode;
  List<TrackModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  String? get error => _error;

  PlayerProvider() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
      notifyListeners();
    });
  }

  Future<void> playTrack(TrackModel track, {List<TrackModel>? queue}) async {
    if (queue != null) {
      _queue = queue;
      _currentIndex = queue.indexWhere((t) => t.id == track.id);
    } else if (_queue.isEmpty || _queue[_currentIndex].id != track.id) {
      _queue = [track];
      _currentIndex = 0;
    }

    _currentTrack = track;
    _error = null;
    _isPlaying = true;
    notifyListeners();

    try {
      if (track.localPath != null) {
        await _player.setFilePath(track.localPath!);
      } else if (track.audioUrl != null) {
        await _player.setUrl(track.audioUrl!);
      } else {
        _error = 'No audio source available';
        _isPlaying = false;
        notifyListeners();
        return;
      }
      await _player.play();
    } catch (e) {
      _error = 'Playback failed: $e';
      _isPlaying = false;
      debugPrint('Playback error: $e');
    }
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    _isPlaying = _player.playing;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = 0;
    } else {
      return;
    }
    await playTrack(_queue[_currentIndex]);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = _queue.length - 1;
    } else {
      return;
    }
    await playTrack(_queue[_currentIndex]);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _player.setVolume(volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    notifyListeners();
  }

  void toggleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  void setQueue(List<TrackModel> tracks, {int startIndex = 0}) {
    _queue = tracks;
    _currentIndex = startIndex;
    notifyListeners();
  }

  void _onTrackComplete() {
    if (_loopMode == LoopMode.one) {
      playTrack(_queue[_currentIndex]);
      return;
    }
    next();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
