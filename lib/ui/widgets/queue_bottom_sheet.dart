import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/player_provider.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const QueueBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final queue = player.queue;
        final currentIndex = player.currentIndex;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Playing Queue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${queue.length} songs',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.shuffle_rounded, size: 16),
                        label: Text(
                          player.isShuffle ? 'Shuffled' : 'Shuffle',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: player.isShuffle
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                        ),
                        onPressed: () => player.toggleShuffle(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.divider, height: 1),

                // Song List
                Expanded(
                  child: queue.isEmpty
                      ? const Center(
                          child: Text(
                            'Queue is empty',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final song = queue[index];
                            final isCurrent = index == currentIndex;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 2,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: isCurrent
                                      ? AppTheme.primaryGradient
                                      : AppTheme.cardGradient,
                                ),
                                child: Center(
                                  child: isCurrent
                                      ? const Icon(
                                          Icons.equalizer_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrent
                                      ? AppTheme.primaryLight
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              trailing: isCurrent
                                  ? const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: AppTheme.accent,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () {
                                player.playSong(song, index: index);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
