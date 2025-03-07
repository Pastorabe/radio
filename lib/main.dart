import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/station_service.dart';
import 'services/audio_service.dart';
import 'services/podcast_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  try {
    print('=== Initialisation de Firebase ===');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase déjà initialisé');
    } else {
      print('Erreur lors de l\'initialisation de Firebase:');
      print(e);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
          lazy: false,
        ),
        ChangeNotifierProvider<StationService>(
          create: (_) => StationService(),
        ),
        ChangeNotifierProvider<AudioService>(
          create: (_) => AudioService(),
        ),
        ChangeNotifierProvider<PodcastService>(
          create: (_) => PodcastService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOIBE LOTERANA MOMBA NY FIFANDRAISANA',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}
