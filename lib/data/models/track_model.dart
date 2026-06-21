class TrackModel {
  final String id;
  final String title;
  final String author;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? audioUrl;
  final bool isDownloaded;
  final String? localPath;
  final DateTime? addedDate;

  TrackModel({
    required this.id,
    required this.title,
    required this.author,
    this.thumbnailUrl,
    this.duration,
    this.audioUrl,
    this.isDownloaded = false,
    this.localPath,
    this.addedDate,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? author,
    String? thumbnailUrl,
    Duration? duration,
    String? audioUrl,
    bool? isDownloaded,
    String? localPath,
    DateTime? addedDate,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration?.inSeconds,
      'audioUrl': audioUrl,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'addedDate': addedDate?.millisecondsSinceEpoch,
    };
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      audioUrl: json['audioUrl'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      addedDate: json['addedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['addedDate'] as int)
          : null,
    );
  }
}
