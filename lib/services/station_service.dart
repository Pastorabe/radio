import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/station.dart';

class StationService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<RadioStation> _stations = [];
  RadioStation? _selectedStation;

  // Getters
  List<RadioStation> get stations => _stations;
  RadioStation? get selectedStation => _selectedStation;

  // Récupérer toutes les stations
  Stream<List<RadioStation>> getAllStations() {
    return _database.child('stations').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) {
        // Si aucune station n'existe, initialiser avec les stations de test
        _initializeTestStations();
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _stations = data.entries.map((entry) {
        final stationData = Map<String, dynamic>.from(entry.value as Map);
        stationData['id'] = entry.key;
        return RadioStation.fromJson(stationData);
      }).toList();
      notifyListeners();
      return _stations;
    });
  }

  // Sélectionner une station
  void selectStation(RadioStation station) {
    _selectedStation = station;
    notifyListeners();
  }

  // Désélectionner la station actuelle
  void clearSelectedStation() {
    _selectedStation = null;
    notifyListeners();
  }

  // Initialiser les stations de test
  Future<void> _initializeTestStations() async {
    final stations = [
      RadioStation(
        id: 'radio-feon-ny',
        name: 'Radio Feon\'ny Filazantsara',
        streamUrl: 'https://stream.zeno.fm/0vhq1ykn3qzuv',
        logo: 'https://flm-rff.org/wp-content/uploads/2024/01/radio-feon-ny.jpg',
        slide1: 'https://flm-rff.org/wp-content/uploads/2024/01/slide1.jpg',
        slide2: 'https://flm-rff.org/wp-content/uploads/2024/01/slide2.jpg',
        slide3: 'https://flm-rff.org/wp-content/uploads/2024/01/slide3.jpg',
        description: 'Radio Feon\'ny Filazantsara - La voix de l\'Évangile',
        category: 'Radio',
      ),
      RadioStation(
        id: 'radio-fahazavana',
        name: 'Radio Fahazavana',
        streamUrl: 'https://stream.zeno.fm/b2vfp8yn3qzuv',
        logo: 'https://flm-rff.org/wp-content/uploads/2024/01/radio-fahazavana.jpg',
        slide1: 'https://flm-rff.org/wp-content/uploads/2024/01/slide1.jpg',
        slide2: 'https://flm-rff.org/wp-content/uploads/2024/01/slide2.jpg',
        slide3: 'https://flm-rff.org/wp-content/uploads/2024/01/slide3.jpg',
        description: 'Radio Fahazavana - La lumière de l\'Évangile',
        category: 'Radio',
      ),
      RadioStation(
        id: 'lutheran-radio',
        name: 'Lutheran Radio',
        streamUrl: 'https://stream.zeno.fm/c2vfp8yn3qzuv',
        logo: 'https://flm-rff.org/wp-content/uploads/2024/01/lutheran-radio.jpg',
        slide1: 'https://flm-rff.org/wp-content/uploads/2024/01/slide1.jpg',
        slide2: 'https://flm-rff.org/wp-content/uploads/2024/01/slide2.jpg',
        slide3: 'https://flm-rff.org/wp-content/uploads/2024/01/slide3.jpg',
        description: 'Lutheran Radio - La radio luthérienne',
        category: 'Radio',
      ),
    ];

    // Ajouter chaque station
    for (var station in stations) {
      await addStation(station);
    }
  }

  // Récupérer une station par son ID
  Future<RadioStation?> getStationById(String stationId) async {
    final snapshot = await _database.child('stations/$stationId').get();
    if (!snapshot.exists || snapshot.value == null) return null;
    
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data['id'] = stationId;
    return RadioStation.fromJson(data);
  }

  // Ajouter une nouvelle station
  Future<void> addStation(RadioStation station) async {
    await _database.child('stations/${station.id}').set(station.toJson());
    notifyListeners();
  }

  // Mettre à jour une station
  Future<void> updateStation(RadioStation station) async {
    await _database.child('stations/${station.id}').update(station.toJson());
    notifyListeners();
  }

  // Supprimer une station
  Future<void> deleteStation(String stationId) async {
    await _database.child('stations/$stationId').remove();
    notifyListeners();
  }

  // Forcer l'initialisation des stations de test
  Future<void> initializeTestStations() async {
    await _initializeTestStations();
  }
}
