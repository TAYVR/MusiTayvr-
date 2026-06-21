import 'package:musitayvr/data/models/track_model.dart';

enum DownloadStatus { pending, downloading, completed, failed, paused }

class DownloadTask {
  final String id;
  final TrackModel track;
  final double progress;
  final DownloadStatus status;
  final String? errorMessage;

  DownloadTask({
    required this.id,
    required this.track,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.errorMessage,
  });

  DownloadTask copyWith({
    String? id,
    TrackModel? track,
    double? progress,
    DownloadStatus? status,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id ?? this.id,
      track: track ?? this.track,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
