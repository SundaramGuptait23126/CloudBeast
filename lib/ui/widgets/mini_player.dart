import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/player_provider.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        final progress = (player.duration.inMilliseconds > 0)
            ? (player.position.inMilliseconds / player.duration.inMilliseconds)
                .clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(240),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryLight.withAlpha(51),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(150),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, anim, secAnim) =>
                          const NowPlayingScreen(),
                      transitionsBuilder: (context, anim, secAnim, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thin progress indicator at top of bar with RepaintBoundary
                    RepaintBoundary(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2.5,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.accent,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Mini Artwork
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title and Artist
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Buffering / Loading or Play/Pause Button
                          if (player.isBuffering)
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: Icon(
                                player.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: AppTheme.primaryLight,
                                size: 36,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => player.togglePlayPause(),
                            ),
                          const SizedBox(width: 8),

                          // Skip Next Button
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: AppTheme.textPrimary,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => player.skipNext(),
                          ),
                        ],
                      ),
                    ),
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
