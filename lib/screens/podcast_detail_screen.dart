import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../services/audio_service.dart';

class PodcastDetailScreen extends StatelessWidget {
  final Podcast podcast;

  const PodcastDetailScreen({
    Key? key,
    required this.podcast,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Podcast'),
      ),
      body: Consumer<AudioService>(
        builder: (context, audioService, _) {
          final isCurrentlyPlaying = audioService.currentUrl == podcast.audioUrl &&
              audioService.isPlaying &&
              audioService.currentType == AudioType.podcast;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    podcast.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        podcast.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      // Catégorie
                      Text(
                        podcast.category,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        podcast.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Contrôles de lecture
                      if (isCurrentlyPlaying)
                        StreamBuilder<Duration>(
                          stream: audioService.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = audioService.duration ?? Duration.zero;

                            return Column(
                              children: [
                                // Barre de progression
                                Slider(
                                  value: position.inSeconds.toDouble(),
                                  max: duration.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    audioService.seek(Duration(
                                      seconds: value.toInt(),
                                    ));
                                  },
                                ),
                                // Durées
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(position)),
                                      Text(_formatDuration(duration)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      // Boutons de contrôle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCurrentlyPlaying) ...[
                            IconButton(
                              icon: const Icon(Icons.replay_10),
                              onPressed: () {
                                final position = audioService.duration;
                                if (position != null) {
                                  audioService.seek(
                                    position - const Duration(seconds: 10),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 16),
                          ],
                          FloatingActionButton(
                            onPressed: () {
                              if (isCurrentlyPlaying) {
                                audioService.pause();
                              } else {
                                audioService.playPodcast(
                                  podcast.audioUrl,
                                  title: podcast.title,
                                );
                              }
                            },
                            child: Icon(
                              isCurrentlyPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                          if (isCurrentlyPlaying) ...[
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.forward_30),
                              onPressed: () {
                                final position = audioService.duration;
                                if (position != null) {
                                  audioService.seek(
                                    position + const Duration(seconds: 30),
                                  );
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
