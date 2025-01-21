import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter un nouveau programme
  Future<void> addProgram({
    required String title,
    required String description,
    required String host,
    required String streamUrl,
    required DateTime startTime,
    required DateTime endTime,
    required bool isLive,
    required bool isPodcast,
  }) async {
    await _firestore.collection('programs').add({
      'title': title,
      'description': description,
      'host': host,
      'streamUrl': streamUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isLive': isLive,
      'isPodcast': isPodcast,
      'createdAt': Timestamp.now(),
    });
  }

  // Mettre à jour un programme
  Future<void> updateProgram({
    required String programId,
    required String title,
    required String description,
    required String host,
    required String streamUrl,
    required DateTime startTime,
    required DateTime endTime,
    required bool isLive,
    required bool isPodcast,
  }) async {
    await _firestore.collection('programs').doc(programId).update({
      'title': title,
      'description': description,
      'host': host,
      'streamUrl': streamUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isLive': isLive,
      'isPodcast': isPodcast,
      'updatedAt': Timestamp.now(),
    });
  }

  // Supprimer un programme
  Future<void> deleteProgram(String programId) async {
    await _firestore.collection('programs').doc(programId).delete();
  }

  // Récupérer tous les programmes
  Stream<List<RadioProgram>> getAllPrograms() {
    return _firestore
        .collection('programs')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RadioProgram.fromFirestore(doc)).toList();
    });
  }
}
