import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/logic/search_provider.dart';
import 'package:musitayvr/logic/download_provider.dart';
import 'package:musitayvr/logic/player_provider.dart';
import 'package:musitayvr/core/utils/helpers.dart';
import 'package:musitayvr/presentation/screens/player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MusiTayvr',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          Consumer<PlayerProvider>(
            builder: (context, player, _) {
              if (player.currentTrack != null) {
                return IconButton(
                  icon: const Icon(Icons.music_note_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerScreen(),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search YouTube music...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            context.read<SearchProvider>().search(query.trim());
          }
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.isLoading && searchProvider.results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchProvider.error != null && searchProvider.results.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    searchProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.h),
                  FilledButton(
                    onPressed: () {
                      if (searchProvider.query.isNotEmpty) {
                        searchProvider.search(searchProvider.query);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (searchProvider.results.isEmpty) {
          return _buildEmptyState();
        }

        return _buildResultsList(searchProvider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note_rounded, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'Discover Music',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Search for any song or artist',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(SearchProvider searchProvider) {
    final downloadProvider = context.read<DownloadProvider>();

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      itemCount: searchProvider.results.length,
      itemBuilder: (context, index) {
        final track = searchProvider.results[index];
        final isDownloaded = downloadProvider.isDownloaded(track.id);
        final isDownloading = downloadProvider.isDownloading(track.id);

        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(15.r),
            onTap: () => _onTrackTap(track, searchProvider.results),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SizedBox(
                      width: 72.w,
                      height: 54.w,
                      child: track.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: track.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.music_note),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.music_note),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.music_note),
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 13.sp,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              track.author,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 11.sp,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (track.duration != null) ...[
                              Text(
                                ' • ${Helpers.formatDuration(track.duration!)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 11.sp,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (isDownloading)
                    SizedBox(
                      width: 36.w,
                      height: 36.w,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (isDownloaded)
                    Icon(Icons.check_circle, color: Colors.green, size: 28.sp)
                  else
                    IconButton(
                      icon: Icon(Icons.download_rounded, size: 28.sp),
                      onPressed: () => _downloadTrack(track, searchProvider.results),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTrackTap(TrackModel track, List<TrackModel> allTracks) async {
    final searchProvider = context.read<SearchProvider>();
    final playerProvider = context.read<PlayerProvider>();

    if (track.audioUrl != null) {
      playerProvider.playTrack(track, queue: allTracks);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final fullTrack = await searchProvider.getTrackInfo(track.id);
        if (mounted) Navigator.pop(context);

        if (fullTrack != null && fullTrack.audioUrl != null) {
          _showTrackOptions(fullTrack, allTracks);
        } else {
          _showError('Could not get audio for this track');
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showError('Failed to load track: $e');
      }
    }
  }

  void _downloadTrack(TrackModel track, List<TrackModel> allTracks) async {
    if (track.audioUrl != null) {
      context.read<DownloadProvider>().downloadTrack(track);
      _showSnackBar('Download started: ${track.title}');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final fullTrack = await context.read<SearchProvider>().getTrackInfo(track.id);
        if (mounted) Navigator.pop(context);

        if (fullTrack != null && fullTrack.audioUrl != null) {
          context.read<DownloadProvider>().downloadTrack(fullTrack);
          _showSnackBar('Download started: ${track.title}');
        } else {
          _showError('Could not get audio for this track');
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        _showError('Failed to load track: $e');
      }
    }
  }

  void _showTrackOptions(TrackModel track, List<TrackModel> allTracks) {
    final downloadProvider = context.read<DownloadProvider>();
    final playerProvider = context.read<PlayerProvider>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: track.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: track.thumbnailUrl!,
                        height: 150.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 150.h,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 48),
                      ),
              ),
              SizedBox(height: 16.h),
              Text(
                track.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                track.author,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        downloadProvider.downloadTrack(track);
                        _showSnackBar('Download started: ${track.title}');
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        playerProvider.playTrack(track, queue: allTracks);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play Now'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
