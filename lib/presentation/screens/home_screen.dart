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

  @override
  void dispose() {
    _searchController.dispose();
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
                      MaterialPageRoute(builder: (_) => const PlayerScreen()),
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
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search music, artists...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search_rounded, size: 22.sp),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchProvider>().clearSearch();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        onChanged: (_) => setState(() {}),
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

        return _buildVideoGrid(searchProvider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_outline_rounded, size: 72.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Search YouTube Music',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Find songs, albums, and artists',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid(SearchProvider searchProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      itemCount: searchProvider.results.length,
      itemBuilder: (context, index) {
        final track = searchProvider.results[index];
        return _VideoCard(track: track, allTracks: searchProvider.results);
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  final TrackModel track;
  final List<TrackModel> allTracks;

  const _VideoCard({required this.track, required this.allTracks});

  @override
  Widget build(BuildContext context) {
    final downloadProvider = context.watch<DownloadProvider>();
    final isDownloaded = downloadProvider.isDownloaded(track.id);
    final isDownloading = downloadProvider.isDownloading(track.id);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _onTap(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: track.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: track.thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[800],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note, color: Colors.white54, size: 48),
                            ),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white54, size: 48),
                          ),
                  ),
                ),
                if (track.duration != null)
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        Helpers.formatDuration(track.duration!),
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          track.author,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    IconButton(
                      icon: Icon(Icons.download_done_rounded, color: Colors.green, size: 26.sp),
                      onPressed: null,
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.download_rounded, size: 26.sp),
                      onPressed: () => _onDownload(context),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    final playerProvider = context.read<PlayerProvider>();

    if (track.audioUrl != null) {
      playerProvider.playTrack(track, queue: allTracks);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final fullTrack = await context.read<SearchProvider>().getTrackInfo(track.id);
        if (context.mounted) Navigator.pop(context);

        if (fullTrack != null && fullTrack.audioUrl != null) {
          playerProvider.playTrack(fullTrack, queue: allTracks);
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
          }
        } else {
          _showError(context, 'Could not load audio');
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        _showError(context, 'Failed to load: $e');
      }
    }
  }

  void _onDownload(BuildContext context) async {
    final downloadProvider = context.read<DownloadProvider>();

    if (track.audioUrl != null) {
      downloadProvider.downloadTrack(track);
      _showSnackBar(context, 'Download started');
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final fullTrack = await context.read<SearchProvider>().getTrackInfo(track.id);
        if (context.mounted) Navigator.pop(context);

        if (fullTrack != null && fullTrack.audioUrl != null) {
          downloadProvider.downloadTrack(fullTrack);
          _showSnackBar(context, 'Download started');
        } else {
          _showError(context, 'Could not load audio');
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        _showError(context, 'Failed to load: $e');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
