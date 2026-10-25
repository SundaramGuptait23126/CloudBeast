import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../services/google_drive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GoogleDriveService _driveService = GoogleDriveService();
  int _cacheSizeBytes = 0;
  bool _isLoadingCache = true;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    setState(() => _isLoadingCache = true);
    final size = await _driveService.getCacheSizeBytes();
    if (mounted) {
      setState(() {
        _cacheSizeBytes = size;
        _isLoadingCache = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear Audio Cache?'),
        content: const Text(
          'This will remove all songs downloaded locally on this device. You will still be able to stream them from Google Drive.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _driveService.clearCache();
      await _loadCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio cache cleared successfully.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings & Account'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // User Account Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primary,
                      backgroundImage: (user?.photoUrl != null)
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: (user?.photoUrl == null)
                          ? Text(
                              (user?.name.isNotEmpty == true)
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Not Signed In',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: auth.isDemoMode
                                  ? AppTheme.accent.withAlpha(40)
                                  : AppTheme.success.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              auth.isDemoMode ? 'Demo Mode' : 'Connected to Drive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: auth.isDemoMode
                                    ? AppTheme.accent
                                    : AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Storage & Cache Section
              const Text(
                'STORAGE & OFFLINE PLAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage_rounded,
                          color: AppTheme.accent),
                      title: const Text('Cached Audio Size'),
                      subtitle: Text(
                        _isLoadingCache
                            ? 'Calculating...'
                            : Formatters.formatBytes(_cacheSizeBytes),
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      trailing: TextButton(
                        onPressed: _cacheSizeBytes > 0 ? _clearCache : null,
                        child: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Drive Information
              const Text(
                'GOOGLE DRIVE CONFIGURATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 20, color: AppTheme.primaryLight),
                        SizedBox(width: 10),
                        Text(
                          'Privacy & Access',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'CloudBeats requests read-only access (drive.readonly) solely to scan audio files and stream playback. Your files are never modified or uploaded anywhere.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: const Text(
                    'Disconnect / Sign Out',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.error.withAlpha(100)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await auth.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
