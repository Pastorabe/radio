import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../services/podcast_service.dart';
import '../services/audio_service.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({Key? key}) : super(key: key);

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final podcasts = snapshot.data!;
              if (podcasts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.podcasts, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Aucun podcast disponible'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Initialiser les podcasts'),
                        onPressed: () {
                          podcastService.initializeTestPodcasts().then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Podcasts initialisés')),
                            );
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $error')),
                            );
                          });
                        },
                      ),
                    ],
                  ),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
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
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          podcast.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              podcast.category,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              podcast.durationString,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bouton de lecture
                  Stack(
                    alignment: Alignment.center,
                    children: [
                                           if (audioService.isLoading && audioService.currentUrl == podcast.audioUrl)
                        SizedBox(
                          width: 36,  // Un peu plus grand que l'icône
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                            backgroundColor: Colors.purple.withOpacity(0.2),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          isCurrentlyPlaying ? Icons.pause_circle : Icons.play_circle,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: audioService.isLoading && audioService.currentUrl == podcast.audioUrl
                            ? null  // Désactive le bouton pendant le chargement
                            : () {
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}