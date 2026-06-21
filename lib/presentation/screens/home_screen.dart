import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/logic/search_provider.dart';
import 'package:musitayvr/logic/download_provider.dart';
import 'package:musitayvr/logic/player_provider.dart';
import 'package:musitayvr/presentation/widgets/track_card.dart';
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
      padding: EdgeInsets.all(16.w),
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
          context.read<SearchProvider>().search(query);
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        if (searchProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchProvider.error != null) {
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
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: searchProvider.results.length,
      itemBuilder: (context, index) {
        final track = searchProvider.results[index];
        return TrackCard(
          track: track,
          onTap: () => _onTrackSelected(track),
        );
      },
    );
  }

  void _onTrackSelected(TrackModel track) async {
    final searchProvider = context.read<SearchProvider>();
    await searchProvider.selectTrack(track);

    if (!mounted) return;

    final selected = searchProvider.selectedTrack;
    if (selected != null && selected.audioUrl != null) {
      _showTrackOptions(selected);
    }
  }

  void _showTrackOptions(TrackModel track) {
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
                    : Container(height: 150.h, color: Colors.grey[300]),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                        playerProvider.playTrack(track);
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
}
