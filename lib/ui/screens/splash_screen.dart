import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        if (auth.isAuthenticated) {
          return const HomeScreen();
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E1035),
                  Color(0xFF0F172A),
                  Color(0xFF090D16),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // App Logo Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(128),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.cloud_sync_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // App Title & Tagline
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stream and play all songs stored directly in your Google Drive',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const Spacer(),

                    // Features highlight
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withAlpha(150),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.divider.withAlpha(100),
                        ),
                      ),
                      child: const Column(
                        children: [
                          _FeatureRow(
                            icon: Icons.folder_special_rounded,
                            title: 'Auto-scans your Drive for audio files',
                          ),
                          SizedBox(height: 12),
                          _FeatureRow(
                            icon: Icons.bolt_rounded,
                            title: 'Direct streaming & local caching',
                          ),
                          SizedBox(height: 12),
                          _FeatureRow(
                            icon: Icons.lock_outline_rounded,
                            title: 'Safe read-only Google OAuth',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.account_circle, size: 22),
                        label: const Text(
                          'Connect Google Drive',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: AppTheme.primary.withAlpha(100),
                        ),
                        onPressed: () async {
                          final success = await auth.signInWithGoogle();
                          if (!context.mounted) return;
                          if (!success && auth.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(auth.errorMessage!),
                                backgroundColor: AppTheme.error,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Demo / Quick Test Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_circle_outline_rounded,
                            size: 20),
                        label: const Text(
                          'Try Demo Mode (Instant Preview)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => auth.enableDemoMode(),
                      ),
                    ),

                    const SizedBox(height: 24),
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FeatureRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.accent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
