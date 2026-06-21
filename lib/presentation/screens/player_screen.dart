import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:musitayvr/core/utils/helpers.dart';
import 'package:musitayvr/logic/player_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final track = player.currentTrack;
        if (track == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Player')),
            body: const Center(child: Text('No track selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            actions: [
              IconButton(
                icon: const Icon(Icons.queue_music_rounded),
                onPressed: () => _showQueue(context, player),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Expanded(
                  child: _buildArtwork(context, player),
                ),
                _buildTrackInfo(context, player),
                SizedBox(height: 24.h),
                _buildProgressBar(context, player),
                SizedBox(height: 24.h),
                _buildControls(context, player),
                SizedBox(height: 16.h),
                _buildVolumeControl(context, player),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtwork(BuildContext context, PlayerProvider player) {
    final track = player.currentTrack!;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 280.w,
          height: 280.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: track.thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: track.thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(Icons.music_note, size: 64),
                )
              : const Icon(Icons.music_note, size: 64),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(BuildContext context, PlayerProvider player) {
    final track = player.currentTrack!;
    return Column(
      children: [
        Text(
          track.title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Text(
          track.author,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, PlayerProvider player) {
    final position = player.position;
    final duration = player.duration;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.h,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: duration.inSeconds > 0
                ? position.inSeconds / duration.inSeconds
                : 0.0,
            onChanged: (value) {
              final pos = Duration(seconds: (value * duration.inSeconds).round());
              player.seek(pos);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Helpers.formatDuration(position),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                Helpers.formatDuration(duration),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, PlayerProvider player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            player.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
            size: 24.sp,
          ),
          onPressed: player.toggleShuffle,
        ),
        SizedBox(width: 16.w),
        IconButton(
          icon: Icon(Icons.skip_previous_rounded, size: 32.sp),
          onPressed: player.previous,
        ),
        SizedBox(width: 16.w),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: IconButton(
            icon: Icon(
              player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36.sp,
              color: Colors.white,
            ),
            onPressed: player.playPause,
          ),
        ),
        SizedBox(width: 16.w),
        IconButton(
          icon: Icon(Icons.skip_next_rounded, size: 32.sp),
          onPressed: player.next,
        ),
        SizedBox(width: 16.w),
        IconButton(
          icon: Icon(
            player.loopMode == LoopMode.off
                ? Icons.repeat_rounded
                : player.loopMode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_on_rounded,
            size: 24.sp,
          ),
          onPressed: player.toggleLoopMode,
        ),
      ],
    );
  }

  Widget _buildVolumeControl(BuildContext context, PlayerProvider player) {
    return Row(
      children: [
        Icon(Icons.volume_down_rounded, size: 20.sp),
        Expanded(
          child: Slider(
            value: player.volume,
            onChanged: (value) => player.setVolume(value),
          ),
        ),
        Icon(Icons.volume_up_rounded, size: 20.sp),
      ],
    );
  }

  void _showQueue(BuildContext context, PlayerProvider player) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Queue',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12.h),
              if (player.queue.isEmpty)
                const Text('Queue is empty')
              else
                ...player.queue.asMap().entries.map((entry) {
                  final index = entry.key;
                  final track = entry.value;
                  final isCurrent = index == player.currentIndex;
                  return ListTile(
                    leading: isCurrent
                        ? Icon(Icons.play_arrow_rounded, color: Theme.of(context).colorScheme.secondary)
                        : Text('${index + 1}'),
                    title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(track.author, maxLines: 1, overflow: TextOverflow.ellipsis),
                    selected: isCurrent,
                    onTap: () {
                      player.playTrack(track, queue: player.queue);
                      Navigator.pop(context);
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
