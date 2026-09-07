import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.create();
  runApp(LexiShikhiApp(appState: appState));
}

class LexiShikhiApp extends StatelessWidget {
  const LexiShikhiApp({super.key, required this.appState});

  final AppState appState;

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3157C8),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: dark ? const Color(0xFF111318) : const Color(0xFFF7F8FC),
      appBarTheme: AppBarThemeData(
        surfaceTintColor: Colors.transparent,
        backgroundColor: dark ? const Color(0xFF111318) : const Color(0xFFF7F8FC),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1C1F26) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LexiShikhi',
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: appState.onboardingDone
              ? HomeShell(appState: appState)
              : OnboardingScreen(appState: appState),
        );
      },
    );
  }
}
