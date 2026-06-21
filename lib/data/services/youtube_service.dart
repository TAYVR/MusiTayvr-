import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:musitayvr/data/models/track_model.dart';

class _CustomYoutubeHttpClient extends YoutubeHttpClient {
  @override
  Map<String, String> get headers => {
        ...super.headers,
        'user-agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) '
            'Version/17.0 Mobile/15E148 Safari/604.1',
      };
}

class YouTubeService {
  late final YoutubeExplode _yt;

  YouTubeService() {
    _yt = YoutubeExplode(_CustomYoutubeHttpClient());
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
          .take(20)
          .toList();
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw Exception('CORS error: YouTube blocks requests from web browser. Use iOS device.');
      }
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      }
      throw Exception('YouTube search failed. Try again later.');
    }
  }

  Future<TrackModel> getTrackInfo(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) {
        throw Exception('No audio streams available');
      }

      final bestAudio = audioStreams
          .reduce((a, b) => a.bitrate.bitsPerSecond > b.bitrate.bitsPerSecond ? a : b);

      return TrackModel(
        id: video.id.value,
        title: video.title,
        author: video.author.toString(),
        thumbnailUrl: video.thumbnails.standardResUrl,
        duration: video.duration,
        audioUrl: bestAudio.url.toString(),
      );
    } catch (e) {
      if (e.toString().contains('Failed to fetch')) {
        throw Exception('CORS error: YouTube blocks requests from web browser. Use iOS device.');
      }
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      }
      throw Exception('Failed to get track info. Try again later.');
    }
  }

  void dispose() {
    _yt.close();
  }
}
