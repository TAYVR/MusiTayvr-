import 'package:flutter/foundation.dart';
import 'package:musitayvr/data/database/hive_database.dart';
import 'package:musitayvr/data/models/download_task.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/data/services/download_service.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  final List<TrackModel> _downloadedTracks = [];
  final Map<String, DownloadTask> _activeDownloads = {};
  final bool _isLoading = false;

  List<TrackModel> get downloadedTracks => _downloadedTracks;
  Map<String, DownloadTask> get activeDownloads => _activeDownloads;
  bool get isLoading => _isLoading;

  void loadDownloadedTracks() {
    _downloadedTracks.clear();
    _downloadedTracks.addAll(HiveDatabase.getAllTracks());
    notifyListeners();
  }

  Future<void> downloadTrack(TrackModel track) async {
    if (_activeDownloads.containsKey(track.id)) return;

    final task = DownloadTask(
      id: track.id,
      track: track,
      status: DownloadStatus.pending,
    );
    _activeDownloads[track.id] = task;
    notifyListeners();

    await _downloadService.downloadTrack(
      track,
      onProgress: (progress) {
        _activeDownloads[track.id] = _activeDownloads[track.id]!.copyWith(
          progress: progress,
        );
        notifyListeners();
      },
      onStatusChange: (status) {
        _activeDownloads[track.id] = _activeDownloads[track.id]!.copyWith(
          status: status,
        );
        notifyListeners();
      },
    );

    final completedTask = _activeDownloads[track.id];
    if (completedTask != null && completedTask.status == DownloadStatus.completed) {
      await HiveDatabase.saveTrack(completedTask.track);
      _downloadedTracks.insert(0, completedTask.track);
      _activeDownloads.remove(track.id);
    }
    notifyListeners();
  }

  Future<void> deleteTrack(TrackModel track) async {
    if (track.localPath != null) {
      await _downloadService.deleteFile(track.localPath!);
    }
    await HiveDatabase.deleteTrack(track.id);
    _downloadedTracks.removeWhere((t) => t.id == track.id);
    notifyListeners();
  }

  void cancelDownload(String taskId) {
    _downloadService.cancelDownload(taskId);
    _activeDownloads.remove(taskId);
    notifyListeners();
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
