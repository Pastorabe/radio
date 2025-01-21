import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum AudioType {
  radio,
  podcast,
  none
}

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? _currentUrl;
  String? _currentTitle;
  AudioType _currentType = AudioType.none;
  bool _isPlaying = false;
  bool _isLoading = false;

  AudioService() {
    // Écouter les changements d'état du lecteur
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      // Si l'état est en train de jouer, on arrête le chargement
      if (state.playing) {
        _isLoading = false;
      }
      notifyListeners();
    });

    // Écouter les erreurs
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        print('Erreur de lecture: $e');
        _isPlaying = false;
        _isLoading = false;  // Réinitialiser le chargement en cas d'erreur
        notifyListeners();
      },
    );
  }

  // Getters
  String? get currentUrl => _currentUrl;
  String? get currentTitle => _currentTitle;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  AudioType get currentType => _currentType;
  Duration? get duration => _player.duration;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  // Jouer un flux audio (radio ou podcast)
  Future<void> playAudio(String url, {String? title, required AudioType type}) async {
    try {
      _isLoading = true;  // Début du chargement
      notifyListeners();

      // Si c'est la même source et qu'elle est en cours de lecture, on met en pause
      if (url == _currentUrl && _isPlaying) {
        await pause();
        return;
      }

      // Si c'est une nouvelle source, on arrête la lecture en cours
      if (url != _currentUrl) {
        await stop();
      }

      _currentUrl = url;
      _currentTitle = title ?? (type == AudioType.radio ? 'Radio en Direct' : 'Podcast');
      _currentType = type;
      
      // Configurer le lecteur
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        preload: true,
      );
      
      await _player.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la lecture ${type == AudioType.radio ? "radio" : "podcast"}: $e');
      _isPlaying = false;
      _isLoading = false;  // En cas d'erreur, on arrête le chargement
      notifyListeners();
      rethrow;
    }
  }

  // Jouer un flux radio (wrapper pour la compatibilité)
  Future<void> playRadio(String url, {String? title}) async {
    await playAudio(url, title: title, type: AudioType.radio);
  }

  // Jouer un podcast (wrapper pour la compatibilité)
  Future<void> playPodcast(String url, {String? title}) async {
    await playAudio(url, title: title, type: AudioType.podcast);
  }

  // Mettre en pause
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // Reprendre la lecture
  Future<void> resume() async {
    if (_currentUrl != null) {
      await _player.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  // Arrêter la lecture
  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
    _currentTitle = null;
    _currentType = AudioType.none;
    _isPlaying = false;
    notifyListeners();
  }

  // Chercher une position dans le podcast
  Future<void> seek(Duration position) async {
    if (_currentType == AudioType.podcast) {
      await _player.seek(position);
    }
  }

  // Nettoyer les ressources
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}