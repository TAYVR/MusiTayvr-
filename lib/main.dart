import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:musitayvr/core/theme/app_theme.dart';
import 'package:musitayvr/core/utils/helpers.dart';
import 'package:musitayvr/data/database/hive_database.dart';
import 'package:musitayvr/data/models/track_model.dart';
import 'package:musitayvr/logic/search_provider.dart';
import 'package:musitayvr/logic/download_provider.dart';
import 'package:musitayvr/logic/player_provider.dart';
import 'package:musitayvr/presentation/screens/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  runApp(const MusiTayvrApp());
}

class MusiTayvrApp extends StatefulWidget {
  const MusiTayvrApp({super.key});

  @override
  State<MusiTayvrApp> createState() => _MusiTayvrAppState();
}

class _MusiTayvrAppState extends State<MusiTayvrApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = HiveDatabase.darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggleTheme(bool isDark) async {
    await HiveDatabase.setDarkMode(isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()..loadDownloadedTracks()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'MusiTayvr',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeMode,
            home: MainShell(onThemeToggle: _toggleTheme),
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final void Function(bool isDark) onThemeToggle;

  const MainShell({super.key, required this.onThemeToggle});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const _DownloadsPlaceholder(),
          _SettingsPlaceholder(onThemeToggle: widget.onThemeToggle),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DownloadsPlaceholder extends StatelessWidget {
  const _DownloadsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, provider, _) {
        return _buildDownloadsScreen(context, provider);
      },
    );
  }
}

Widget _buildDownloadsScreen(BuildContext context, DownloadProvider provider) {
  return Scaffold(
    appBar: AppBar(title: const Text('Downloads')),
    body: provider.downloadedTracks.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No downloads yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Search and download your favorite music',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: provider.downloadedTracks.length,
            itemBuilder: (context, index) {
              final track = provider.downloadedTracks[index];
              return _TrackListItem(track: track, provider: provider);
            },
          ),
  );
}

class _SettingsPlaceholder extends StatelessWidget {
  final void Function(bool isDark) onThemeToggle;

  const _SettingsPlaceholder({required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: HiveDatabase.darkMode,
                onChanged: (value) {
                  onThemeToggle(value);
                },
              ),
            ),
            SizedBox(height: 8.h),
            Card(
              child: SwitchListTile(
                title: const Text('High Quality Audio'),
                subtitle: const Text('Download in best quality'),
                value: HiveDatabase.audioQualityHigh,
                onChanged: (value) async {
                  await HiveDatabase.setAudioQualityHigh(value);
                },
              ),
            ),
            const Spacer(),
            Text(
              'MusiTayvr v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _TrackListItem extends StatelessWidget {
  final TrackModel track;
  final DownloadProvider provider;

  const _TrackListItem({required this.track, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.r),
        onTap: () {
          final player = context.read<PlayerProvider>();
          player.playTrack(track, queue: provider.downloadedTracks);
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: track.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: track.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey[300]),
                          errorWidget: (_, __, ___) => Icon(Icons.music_note, color: Colors.grey),
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
                    SizedBox(height: 2.h),
                    Text(
                      track.author,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (track.duration != null)
                Text(
                  Helpers.formatDuration(track.duration!),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              SizedBox(width: 4.w),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => provider.deleteTrack(track),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
