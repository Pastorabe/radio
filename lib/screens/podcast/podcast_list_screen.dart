import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/podcast.dart';
import '../../services/podcast_service.dart';
import '../../services/audio_service.dart';

class PodcastListScreen extends StatelessWidget {
  const PodcastListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcasts'),
      ),
      body: Consumer<PodcastService>(
        builder: (context, podcastService, _) {
          return StreamBuilder<List<Podcast>>(
            stream: podcastService.getPodcasts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final podcasts = snapshot.data!;
              if (podcasts.isEmpty) {
                return const Center(
                  child: Text('Aucun podcast disponible'),
                );
              }

              return ListView.builder(
                itemCount: podcasts.length,
                itemBuilder: (context, index) {
                  final podcast = podcasts[index];
                  return PodcastListItem(podcast: podcast);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class PodcastListItem extends StatelessWidget {
  final Podcast podcast;

  const PodcastListItem({
    Key? key,
    required this.podcast,
  }) : super(key: key);

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$secs'
        : '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final isCurrentlyPlaying = audioService.currentUrl == podcast.audioUrl &&
            audioService.isPlaying &&
            audioService.currentType == AudioType.podcast;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () {
              if (isCurrentlyPlaying) {
                audioService.pause();
              } else {
                // Si la radio est en cours, elle sera automatiquement arrêtée
                audioService.playPodcast(
                  podcast.audioUrl,
                  title: podcast.title,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      podcast.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          podcast.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(podcast.duration),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bouton de lecture
                  IconButton(
                    icon: Icon(
                      isCurrentlyPlaying ? Icons.pause_circle : Icons.play_circle,
                      size: 36,
                      color: Theme.of(context).primaryColor,
                    ),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
