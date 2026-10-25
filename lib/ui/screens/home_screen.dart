import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/folder_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSongs();
    });
  }

  void _loadSongs() {
    final auth = context.read<AuthProvider>();
    context.read<LibraryProvider>().fetchSongs(isDemo: auth.isDemoMode);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LibraryProvider>(
      builder: (context, auth, library, child) {
        final songs = library.filteredSongs;
        final folderGroups = library.folderGroups;
        final selectedFolder = library.selectedFolderId;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // App Bar Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.cloud_queue_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (auth.isDemoMode) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Rescan Drive',
                            onPressed: library.isLoading ? null : _loadSongs,
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Settings',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider.withAlpha(100)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => library.search(val),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists, or files...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppTheme.textMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  library.search('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Folder & Filter Chips Bar
                if (folderGroups.isNotEmpty)
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        FolderCard(
                          title: 'All Tracks',
                          count: library.allSongs.length,
                          isSelected: selectedFolder == null || selectedFolder == 'all',
                          onTap: () => library.selectFolder(null),
                        ),
                        const SizedBox(width: 8),
                        FolderCard(
                          title: 'Favorites',
                          count: library.favoriteSongs.length,
                          isSelected: selectedFolder == 'favorites',
                          onTap: () => library.selectFolder('favorites'),
                        ),
                        ...folderGroups.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FolderCard(
                              title: entry.key,
                              count: entry.value.length,
                              isSelected: selectedFolder == entry.key,
                              onTap: () => library.selectFolder(entry.key),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                // Stats Bar (Songs Count & Total Drive Size)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (library.totalSizeBytes > 0)
                        Text(
                          'Drive Audio: ${Formatters.formatBytes(library.totalSizeBytes)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),

                // Song List View
                Expanded(
                  child: library.isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppTheme.primary),
                              SizedBox(height: 16),
                              Text(
                                'Scanning Google Drive for music...',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : library.errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_off_rounded,
                                      size: 48,
                                      color: AppTheme.error,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      library.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (library.errorMessage!.toLowerCase().contains('expired') ||
                                        library.errorMessage!.toLowerCase().contains('sign'))
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.account_circle_outlined),
                                        label: const Text('Reconnect Google Drive'),
                                        onPressed: () async {
                                          final success = await auth.signInWithGoogle();
                                          if (success) _loadSongs();
                                        },
                                      )
                                    else
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('Try Again'),
                                        onPressed: _loadSongs,
                                      ),
                                  ],
                                ),
                              ),
                            )
                          : songs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.library_music_outlined,
                                        size: 48,
                                        color: AppTheme.textMuted,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'No songs match your search.'
                                            : 'No audio files found in your Google Drive.',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Upload .mp3, .m4a or .wav files to your Drive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  color: AppTheme.primary,
                                  backgroundColor: AppTheme.surface,
                                  onRefresh: () async => _loadSongs(),
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    ),
                                    cacheExtent: 600,
                                    padding: const EdgeInsets.only(bottom: 90),
                                    itemCount: songs.length,
                                    itemBuilder: (context, index) {
                                      final song = songs[index];

                                      return Selector<PlayerProvider, (bool, bool)>(
                                        selector: (_, p) => (
                                          p.currentSong?.id == song.id,
                                          p.currentSong?.id == song.id && p.isPlaying,
                                        ),
                                        builder: (context, playbackState, _) {
                                          final isCurrent = playbackState.$1;
                                          final isPlaying = playbackState.$2;
                                          final isFav = library.isFavorite(song.id);

                                          return SongTile(
                                            song: song,
                                            isCurrent: isCurrent,
                                            isPlaying: isPlaying,
                                            isFavorite: isFav,
                                            onTap: () {
                                              context.read<PlayerProvider>().playSong(
                                                    song,
                                                    queue: songs,
                                                    index: index,
                                                  );
                                            },
                                            onFavoriteToggle: () {
                                              library.toggleFavorite(song);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                ),

                // Persistent Mini Player with dedicated RepaintBoundary
                const RepaintBoundary(child: MiniPlayer()),
              ],
            ),
          ),
        );
      },
    );
  }
}
