import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';
import '../services/station_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class RadioScreen extends StatelessWidget {
  const RadioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StationService>(
      builder: (context, stationService, _) {
        return StreamBuilder<List<RadioStation>>(
          stream: stationService.getAllStations(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final stations = snapshot.data!;
            if (stations.isEmpty) {
              return const Center(child: Text('Aucune station disponible'));
            }

            return ListView.builder(
              itemCount: stations.length,
              padding: const EdgeInsets.only(bottom: 80), // Espace pour le mini-player
              itemBuilder: (context, index) {
                final station = stations[index];
                return RadioStationCard(station: station);
              },
            );
          },
        );
      },
    );
  }
}

class RadioStationCard extends StatefulWidget {
  final RadioStation station;

  const RadioStationCard({
    Key? key,
    required this.station,
  }) : super(key: key);

  @override
  State<RadioStationCard> createState() => _RadioStationCardState();
}

class _RadioStationCardState extends State<RadioStationCard> {
  final PageController _slideController = PageController();
  int _currentSlide = 0;

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  List<String> _getValidSlides() {
    return [
      widget.station.slide1,
      widget.station.slide2,
      widget.station.slide3,
    ].where((slide) => slide.isNotEmpty && Uri.parse(slide).isAbsolute).toList();
  }

  Widget _buildSlideShow() {
    final slides = _getValidSlides();

    if (slides.isEmpty) {
      return Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: Center(
          child: Icon(
            Icons.radio,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _slideController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: slides[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      debugPrint('Error loading slide: $error');
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error_outline),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (slides.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentSlide == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, _) {
        final isPlaying = audioService.isPlaying && 
                         audioService.currentUrl == widget.station.streamUrl &&
                         audioService.currentType == AudioType.radio;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: isPlaying ? 16 : 8,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                width: 2.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Slides
                _buildSlideShow(),
                
                // Station Info
                InkWell(
                  onTap: () {
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.playRadio(
                        widget.station.streamUrl,
                        title: widget.station.name,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: widget.station.logo,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.radio),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Station Details
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.station.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.station.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.station.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        // Play/Pause Button
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(4),
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              if (audioService.isLoading && audioService.currentUrl == widget.station.streamUrl)
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(.4),
                                ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: audioService.isLoading && audioService.currentUrl == widget.station.streamUrl
                                    ? null
                                    : () {
                                        if (isPlaying) {
                                          audioService.pause();
                                        } else {
                                          audioService.playRadio(
                                            widget.station.streamUrl,
                                            title: widget.station.name,
                                          );
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}