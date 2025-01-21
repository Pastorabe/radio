import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/podcast.dart';

class PodcastService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  PodcastService() {
    debugPrint('Initialisation de PodcastService');
    debugPrint('Database URL: ${FirebaseDatabase.instance.databaseURL}');
  }

  // Obtenir les podcasts depuis Firebase
  Stream<List<Podcast>> getPodcasts() {
    debugPrint('Démarrage du stream getPodcasts()');
    return _database.child('podcasts').onValue.map((event) {
      final snapshot = event.snapshot;
      
      debugPrint('Réception d\'un événement podcast');
      debugPrint('Path: ${snapshot.ref.path}');
      debugPrint('Key: ${snapshot.key}');
      debugPrint('Valeur: ${snapshot.value}');
      
      if (snapshot.value == null) {
        debugPrint('Aucun podcast trouvé dans la base de données');
        return [];
      }

      try {
        if (snapshot.value is! Map) {
          debugPrint('La valeur n\'est pas une Map: ${snapshot.value.runtimeType}');
          return [];
        }

        final data = Map<String, dynamic>.from(snapshot.value as Map);
        debugPrint('Données brutes: $data');
        
        final podcasts = data.entries.map((entry) {
          try {
            debugPrint('Traitement du podcast: ${entry.key}');
            final podcastData = Map<String, dynamic>.from(entry.value as Map);
            podcastData['id'] = entry.key;
            
            final podcast = Podcast.fromJson(podcastData);
            debugPrint('Podcast converti avec succès: ${podcast.title}');
            return podcast;
          } catch (e, stackTrace) {
            debugPrint('Erreur lors de la conversion du podcast ${entry.key}: $e');
            debugPrint('Stack trace: $stackTrace');
            return null;
          }
        })
        .where((podcast) => podcast != null)
        .cast<Podcast>()
        .toList();
        
        debugPrint('Nombre de podcasts chargés: ${podcasts.length}');
        if (podcasts.isEmpty) {
          debugPrint('Aucun podcast n\'a pu être converti');
        }
        
        podcasts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return podcasts;
      } catch (e, stackTrace) {
        debugPrint('Erreur lors de la conversion des podcasts: $e');
        debugPrint('Stack trace: $stackTrace');
        return [];
      }
    });
  }

  // Fonction publique pour initialiser les podcasts
  Future<void> initializeTestPodcasts() async {
    try {
      final now = DateTime.now();
      final podcasts = {
        'podcast1': {
          'title': 'Toriteny Alahady',
          'description': 'Kristy no Torinay - I Kor. 1.23',
          'audioUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/toriteny-alahady.mp3',
          'imageUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/Logo-RFF.png',
          'category': 'Toriteny',
          'publishedAt': now.millisecondsSinceEpoch,
          'duration': 1800,
          'isActive': true
        },
        'podcast2': {
          'title': 'Fampianarana',
          'description': 'Fampianarana momba ny finoana',
          'audioUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/001-Faneva-Zaikabe-FIFIL-2024.mp3',
          'imageUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/Logo-RFF.png',
          'category': 'Fampianarana',
          'publishedAt': now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
          'duration': 2700,
          'isActive': true
        },
        'podcast3': {
          'title': 'Fihirana',
          'description': 'Fihirana FFPM',
          'audioUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/fihirana.mp3',
          'imageUrl': 'https://flm-foibe.org/wp-content/uploads/2024/01/Logo-RFF.png',
          'category': 'Fihirana',
          'publishedAt': now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
          'duration': 900,
          'isActive': true
        }
      };

      debugPrint('Tentative d\'initialisation des podcasts: $podcasts');
      await _database.child('podcasts').set(podcasts);
      debugPrint('Podcasts initialisés avec succès');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'initialisation des podcasts: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Récupérer un podcast par son ID
  Future<Podcast?> getPodcastById(String podcastId) async {
    try {
      debugPrint('Récupération du podcast: $podcastId');
      final snapshot = await _database.child('podcasts/$podcastId').get();
      
      if (!snapshot.exists || snapshot.value == null) {
        debugPrint('Podcast $podcastId non trouvé');
        return null;
      }
      
      debugPrint('Données du podcast trouvées: ${snapshot.value}');
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data['id'] = podcastId;
      
      final podcast = Podcast.fromJson(data);
      debugPrint('Podcast récupéré: ${podcast.title}');
      return podcast;
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la récupération du podcast: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  // Ajouter un nouveau podcast
  Future<void> addPodcast(Podcast podcast) async {
    try {
      final Map<String, dynamic> data = podcast.toJson();
      await _database.child('podcasts/${podcast.id}').set(data);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de l\'ajout du podcast: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Mettre à jour un podcast
  Future<void> updatePodcast(Podcast podcast) async {
    try {
      final Map<String, dynamic> data = podcast.toJson();
      await _database.child('podcasts/${podcast.id}').update(data);
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la mise à jour du podcast: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Supprimer un podcast
  Future<void> deletePodcast(String podcastId) async {
    try {
      await _database.child('podcasts/$podcastId').remove();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Erreur lors de la suppression du podcast: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
