import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PodcastPlayer extends StatefulWidget {
  final String url;
  final String title;
  
  const PodcastPlayer({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<PodcastPlayer> createState() => _PodcastPlayerState();
}

class _PodcastPlayerState extends State<PodcastPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Configure les écouteurs d'événements
      _player.playerStateStream.listen((playerState) {
        setState(() {
          _isPlaying = playerState.playing;
          _isLoading = playerState.processingState == ProcessingState.loading ||
                      playerState.processingState == ProcessingState.buffering;
        });
      });

      // Configure la source audio
      await _player.setUrl(widget.url);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur de chargement';
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_hasError) {
      // Réessayer en cas d'erreur
      await _initializePlayer();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erreur de lecture';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Bouton de lecture avec indicateur d'état
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    _hasError ? Icons.refresh : (_isPlaying ? Icons.pause : Icons.play_arrow),
                    color: _hasError ? Colors.red : Colors.purple,
                  ),
                  onPressed: _togglePlayPause,
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Titre et message d'erreur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_hasError)
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
