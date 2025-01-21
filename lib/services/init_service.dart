import 'package:cloud_firestore/cloud_firestore.dart';

class InitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeStations() async {
    final stations = [
      {
        'name': 'Radio RFF',
        'location': 'Bujumbura, Burundi',
        'streamUrl': 'https://fpsnew1.listen2myradio.com:2199/listen.php?ip=82.145.63.6&port=8622&type=s1',
        'imageUrl': 'https://example.com/rff.png',
        'isActive': true,
      },
      {
        'name': 'Radio RFF Stream',
        'location': 'Bujumbura, Burundi',
        'streamUrl': 'http://fpsnew1.listen2myradio.com:8622/stream',
        'imageUrl': 'https://example.com/rff-stream.png',
        'isActive': true,
      },
      {
        'name': 'Radio RFF Backup',
        'location': 'Bujumbura, Burundi',
        'streamUrl': 'http://fpsnew1.listen2myradio.com:8622/;',
        'imageUrl': 'https://example.com/rff-backup.png',
        'isActive': false,
      },
    ];

    final batch = _firestore.batch();
    
    // Vérifie si la collection est vide avant d'ajouter les stations
    final snapshot = await _firestore.collection('stations').get();
    if (snapshot.docs.isEmpty) {
      for (var station in stations) {
        final ref = _firestore.collection('stations').doc();
        batch.set(ref, {
          ...station,
          'createdAt': Timestamp.now(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> initializePrograms() async {
    final programs = [
      {
        'title': 'Matinale RFF',
        'description': 'Le meilleur de la musique pour bien commencer la journée',
        'host': 'Jean-Paul',
        'streamUrl': 'https://fpsnew1.listen2myradio.com:2199/listen.php?ip=82.145.63.6&port=8622&type=s1',
        'startTime': DateTime.now().copyWith(hour: 6, minute: 0),
        'endTime': DateTime.now().copyWith(hour: 9, minute: 0),
        'isLive': true,
        'isPodcast': false,
      },
      {
        'title': 'Midi Info',
        'description': 'L\'actualité du jour en détail',
        'host': 'Marie',
        'streamUrl': 'http://fpsnew1.listen2myradio.com:8622/stream',
        'startTime': DateTime.now().copyWith(hour: 12, minute: 0),
        'endTime': DateTime.now().copyWith(hour: 13, minute: 0),
        'isLive': true,
        'isPodcast': true,
      },
      {
        'title': 'Soirée Détente',
        'description': 'Musique douce et ambiance zen',
        'host': 'Sophie',
        'streamUrl': 'http://fpsnew1.listen2myradio.com:8622/;',
        'startTime': DateTime.now().copyWith(hour: 20, minute: 0),
        'endTime': DateTime.now().copyWith(hour: 22, minute: 0),
        'isLive': true,
        'isPodcast': true,
      },
    ];

    final batch = _firestore.batch();
    
    // Vérifie si la collection est vide avant d'ajouter les programmes
    final snapshot = await _firestore.collection('programs').get();
    if (snapshot.docs.isEmpty) {
      for (var program in programs) {
        final ref = _firestore.collection('programs').doc();
        batch.set(ref, {
          ...program,
          'startTime': Timestamp.fromDate(program['startTime'] as DateTime),
          'endTime': Timestamp.fromDate(program['endTime'] as DateTime),
          'createdAt': Timestamp.now(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> initializeAll() async {
    await initializeStations();
    await initializePrograms();
  }
}
