import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class StationList extends StatelessWidget {
  final List<RadioStation> stations;
  final RadioStation? selectedStation;
  final Function(RadioStation) onStationSelected;

  const StationList({
    Key? key,
    required this.stations,
    required this.selectedStation,
    required this.onStationSelected,
  }) : super(key: key);

  Widget _buildStationLogo(RadioStation station) {
    if (station.logo.isEmpty || !Uri.parse(station.logo).isAbsolute) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: station.logo,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('Error loading logo for station ${station.name}: $error');
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radio,
            color: Colors.white.withOpacity(0.7),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'STATION',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationSlides(RadioStation station) {
    final slides = [
      station.slide1,
      station.slide2,
      station.slide3,
    ].where((slide) => slide.isNotEmpty && Uri.parse(slide).isAbsolute).toList();

    if (slides.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
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

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: slides.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stations.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final station = stations[index];
        final isSelected = selectedStation?.id == station.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onStationSelected(station),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Slides
                _buildStationSlides(station),
                
                // Station Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: ClipOval(
                          child: _buildStationLogo(station),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Station Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (station.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                station.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Play Button
                      IconButton(
                        icon: Icon(
                          isSelected ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => onStationSelected(station),
                      ),
                    ],
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

class StationListPage extends StatelessWidget {
  const StationListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StationService>(
      builder: (context, stationService, child) {
        final selectedStation = stationService.selectedStation;
        final stations = stationService.stations;

        if (stations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return StationList(
          stations: stations,
          selectedStation: selectedStation,
          onStationSelected: (station) {
            stationService.selectStation(station);
          },
        );
      },
    );
  }
}
