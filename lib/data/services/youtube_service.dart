import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:musitayvr/data/models/track_model.dart';

class YouTubeService {
  late final YoutubeExplode _yt;

  YouTubeService() {
    _yt = YoutubeExplode();
  }

  Future<List<TrackModel>> search(String query) async {
    try {
      final results = await _yt.search(query);
      return results
          .map((r) => TrackModel(
                id: r.id.value,
                title: r.title,
                author: r.author,
                thumbnailUrl: r.thumbnails.standardResUrl,
                duration: r.duration,
              ))
          .take(30)
          .toList();
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<String?> getAudioUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) return null;
      final bestAudio = audioStreams
          .reduce((a, b) => a.bitrate.bitsPerSecond > b.bitrate.bitsPerSecond ? a : b);
      return bestAudio.url.toString();
    } catch (e) {
      return null;
    }
  }

  Future<TrackModel> getTrackInfo(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final audioUrl = await getAudioUrl(videoId);

      return TrackModel(
        id: video.id.value,
        title: video.title,
        author: video.author.toString(),
        thumbnailUrl: video.thumbnails.standardResUrl,
        duration: video.duration,
        audioUrl: audioUrl,
      );
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to get track info: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
