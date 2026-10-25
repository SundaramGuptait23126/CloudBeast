import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/drive_song.dart';

class SongTile extends StatelessWidget {
  final DriveSong song;
  final bool isPlaying;
  final bool isCurrent;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onMoreOptions;

  const SongTile({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.isCurrent,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.primary.withAlpha(25) // ~0.1
            : AppTheme.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppTheme.primary.withAlpha(102) // ~0.4
              : AppTheme.divider.withAlpha(77),
          width: isCurrent ? 1.2 : 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Album Art / File Type Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isCurrent
                        ? AppTheme.primaryGradient
                        : AppTheme.cardGradient,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isCurrent
                          ? (isPlaying ? Icons.equalizer_rounded : Icons.pause_rounded)
                          : Icons.music_note_rounded,
                      color: isCurrent ? Colors.white : AppTheme.primaryLight,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent
                              ? AppTheme.primaryLight
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              song.fileExtension,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                          if (song.size != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•  ${Formatters.formatBytes(song.size)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppTheme.secondary : AppTheme.textMuted,
                    size: 20,
                  ),
                  onPressed: onFavoriteToggle,
                ),

                if (onMoreOptions != null)
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    onPressed: onMoreOptions,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
