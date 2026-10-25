import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FolderCard extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const FolderCard({
    super.key,
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.surfaceVariant.withAlpha(150),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : AppTheme.divider.withAlpha(80),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.folder_open_rounded
                  : Icons.folder_rounded,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.accent,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(51)
                    : AppTheme.surface.withAlpha(180),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
