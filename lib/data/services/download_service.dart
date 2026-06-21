import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/data/models/download_task.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${dir.path}/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir.path;
  }

  Future<DownloadTask> downloadTrack(
    TrackModel track, {
    required void Function(double progress) onProgress,
    required void Function(DownloadStatus status) onStatusChange,
  }) async {
    if (track.audioUrl == null) {
      return DownloadTask(
        id: track.id,
        track: track,
        status: DownloadStatus.failed,
        errorMessage: 'No audio URL available',
      );
    }

    final taskId = track.id;
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    onStatusChange(DownloadStatus.downloading);

    try {
      final path = await _localPath;
      final fileName = '${_sanitizeFileName(track.title)}.mp3';
      final filePath = '$path/$fileName';

      await _dio.download(
        track.audioUrl!,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          if (total > 0) {
            final progress = count / total;
            onProgress(progress.clamp(0.0, 1.0));
          }
        },
      );

      final downloadedTrack = track.copyWith(
        isDownloaded: true,
        localPath: filePath,
        addedDate: DateTime.now(),
      );

      onStatusChange(DownloadStatus.completed);
      _cancelTokens.remove(taskId);

      return DownloadTask(
        id: taskId,
        track: downloadedTrack,
        progress: 1.0,
        status: DownloadStatus.completed,
      );
    } on DioException catch (e) {
      if (cancelToken.isCancelled) {
        onStatusChange(DownloadStatus.paused);
        return DownloadTask(
          id: taskId,
          track: track,
          progress: 0.0,
          status: DownloadStatus.paused,
        );
      }
      onStatusChange(DownloadStatus.failed);
      return DownloadTask(
        id: taskId,
        track: track,
        status: DownloadStatus.failed,
        errorMessage: e.message,
      );
    } catch (e) {
      onStatusChange(DownloadStatus.failed);
      return DownloadTask(
        id: taskId,
        track: track,
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void cancelDownload(String taskId) {
    _cancelTokens[taskId]?.cancel();
    _cancelTokens.remove(taskId);
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
  }
}
