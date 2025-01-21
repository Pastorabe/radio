import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/station_service.dart';
import '../services/podcast_service.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = true;
  String _loadingText = 'Chargement...';
  double _progress = 0.0;
  bool _stationsLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateProgress(String message) {
    if (!mounted) return;
    setState(() {
      _loadingText = message;
    });
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Charger les stations
      _updateProgress('Chargement des stations...');
      final stationService = Provider.of<StationService>(context, listen: false);
      
      stationService.getAllStations().listen(
        (stations) async {
          if (!_stationsLoaded) {
            _stationsLoaded = true;
            
            // Précharger les images
            _updateProgress('Préchargement des images...');
            await _precacheStationImages(stations);
            
            // Charger les podcasts
            _updateProgress('Chargement des podcasts...');
            final podcastService = Provider.of<PodcastService>(context, listen: false);
            
            await podcastService.getPodcasts().first;
            
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingText = 'Chargement terminé';
              });
              
              // Attendre un peu pour montrer le chargement complet
              await Future.delayed(const Duration(milliseconds: 800));
              
              // Navigation vers la page d'accueil
              Navigator.of(context).pushReplacementNamed('/home');
            }
          }
        },
        onError: (error) {
          _handleError('Erreur lors du chargement des stations');
        },
      );
    } catch (e) {
      _handleError('Erreur lors de l\'initialisation');
    }
  }

  Future<void> _precacheStationImages(List<RadioStation> stations) async {
    final imagesToCache = <Future<void>>[];
    
    for (final station in stations) {
      // Précharger le logo
      if (station.logo.isNotEmpty) {
        imagesToCache.add(
          precacheImage(
            CachedNetworkImageProvider(station.logo),
            context,
          ).catchError((e) => debugPrint('Erreur de préchargement du logo: $e')),
        );
      }

      // Précharger les slides
      final slides = [station.slide1, station.slide2, station.slide3]
          .where((slide) => slide.isNotEmpty)
          .toList();

      for (final slide in slides) {
        imagesToCache.add(
          precacheImage(
            CachedNetworkImageProvider(slide),
            context,
          ).catchError((e) => debugPrint('Erreur de préchargement du slide: $e')),
        );
      }
    }

    // Attendre que toutes les images soient préchargées
    await Future.wait(imagesToCache);
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() {
      _loadingText = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ou titre animé
              FadeTransition(
                opacity: _animation,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/foibe.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kristy no torinay!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Indicateur de progression
              if (_isLoading) ...[
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _loadingText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
