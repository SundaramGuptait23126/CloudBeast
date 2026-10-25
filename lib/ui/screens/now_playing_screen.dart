import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../widgets/queue_bottom_sheet.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlayerProvider, LibraryProvider>(
      builder: (context, player, library, child) {
        final song = player.currentSong;

        if (player.isPlaying) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          _rotationController.stop();
        }

        if (song == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('No song currently playing')),
          );
        }

        final isFav = library.isFavorite(song.id);
        final currentMs = player.position.inMilliseconds.toDouble();
        final maxMs = (player.duration.inMilliseconds > 0)
            ? player.duration.inMilliseconds.toDouble()
            : 1.0;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.playerBackgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 32),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Column(
                          children: [
                            const Text(
                              'PLAYING FROM DRIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.folderName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.queue_music_rounded, size: 26),
                          onPressed: () => QueueBottomSheet.show(context),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Center Animated Vinyl Artwork
                    Center(
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF1E1035),
                                Color(0xFF111422),
                                Color(0xFF07090E),
                              ],
                              stops: [0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(80),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.primaryLight.withAlpha(100),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Track Title & Favorite Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? AppTheme.secondary : AppTheme.textMuted,
                            size: 28,
                          ),
                          onPressed: () => library.toggleFavorite(song),
                        ),
                      ],
                    ),

                    // Badges (Extension, Size, Storage Status)
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            song.fileExtension,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                        if (song.size != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            Formatters.formatBytes(song.size),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (song.isCached)
                          const Row(
                            children: [
                              Icon(Icons.offline_pin_rounded,
                                  size: 16, color: AppTheme.success),
                              SizedBox(width: 4),
                              Text(
                                'Cached Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Seek Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: currentMs.clamp(0.0, maxMs),
                        min: 0.0,
                        max: maxMs,
                        onChanged: (val) {
                          player.seek(Duration(milliseconds: val.toInt()));
                        },
                      ),
                    ),

                    // Timestamps
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Formatters.formatDuration(player.position),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            Formatters.formatDuration(player.duration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Playback Controls Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: player.isShuffle
                                ? AppTheme.accent
                                : AppTheme.textMuted,
                            size: 24,
                          ),
                          onPressed: () => player.toggleShuffle(),
                        ),

                        // Skip Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: AppTheme.textPrimary,
                            size: 38,
                          ),
                          onPressed: () => player.skipPrevious(),
                        ),

                        // Play / Pause Circle
                        GestureDetector(
                          onTap: () => player.togglePlayPause(),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(128),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: player.isBuffering
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      player.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                            ),
                          ),
                        ),

                        // Skip Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppTheme.textPrimary,
                            size: 38,
                          ),
                          onPressed: () => player.skipNext(),
                        ),

                        // Loop Mode
                        IconButton(
                          icon: Icon(
                            player.loopMode == LoopMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            color: player.loopMode != LoopMode.off
                                ? AppTheme.accent
                                : AppTheme.textMuted,
                            size: 24,
                          ),
                          onPressed: () => player.toggleLoopMode(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Download / Cache for offline
                    if (!song.isCached)
                      TextButton.icon(
                        icon: player.isCaching
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: player.cachingProgress > 0
                                      ? player.cachingProgress
                                      : null,
                                  color: AppTheme.accent,
                                ),
                              )
                            : const Icon(Icons.download_rounded, size: 18),
                        label: Text(
                          player.isCaching
                              ? 'Caching ${(player.cachingProgress * 100).toStringAsFixed(0)}%...'
                              : 'Cache to Device for Instant Play',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                        ),
                        onPressed: player.isCaching
                            ? null
                            : () => player.cacheCurrentSong(),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
