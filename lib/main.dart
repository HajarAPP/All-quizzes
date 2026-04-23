import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz/Screens/quiz_splash_screen.dart';
import 'package:quiz/services/ad_manager.dart';
import 'package:quiz/utils/theme_provider.dart';

/*
MIT License — Copyright (c) 2024 Muhammad Fiaz
*/

/// Global theme notifier — accessible from anywhere via the static reference.
late ThemeNotifier themeNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();

  // Preload ads
  AdManager().loadInterstitialAd();
  AdManager().loadRewardedAd();

  // Initialize theme
  themeNotifier = ThemeNotifier();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security+ Quiz',
      theme: ThemeNotifier.lightTheme,
      darkTheme: ThemeNotifier.darkTheme,
      themeMode: themeNotifier.mode,
      home: const QuizSplashScreen(),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
    );
  }
}
