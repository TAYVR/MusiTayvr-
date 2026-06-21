import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/core/utils/helpers.dart';

class TrackCard extends StatelessWidget {
  final TrackModel track;
  final VoidCallback onTap;

  const TrackCard({
    super.key,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: track.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: track.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey[300]),
                          errorWidget: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey),
                        )
                      : Container(color: Colors.grey[300], child: const Icon(Icons.music_note)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      track.author,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (track.duration != null)
                Text(
                  Helpers.formatDuration(track.duration!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
