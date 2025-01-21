import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';

class PersistentPlayer extends StatelessWidget {
  const PersistentPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        if (!audioService.isPlaying && audioService.currentUrl == null) {
          return const SizedBox.shrink();
        }

        final isPodcast = audioService.currentType == AudioType.podcast;
        
        return Container(
          height: 60,
          color: Theme.of(context).primaryColor,
          child: Row(
            children: [
              // Bouton lecture/pause
              IconButton(
                icon: Icon(
                  audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (audioService.isPlaying) {
                    audioService.pause();
                  } else {
                    audioService.resume();
                  }
                },
              ),
              // Titre et type
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audioService.currentTitle ?? 'En lecture',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isPodcast ? 'Podcast' : 'Radio en Direct',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton fermer
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => audioService.stop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
