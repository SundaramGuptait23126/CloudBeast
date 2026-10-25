import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CloudBeatsApp());
}

class CloudBeatsApp extends StatelessWidget {
  const CloudBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
