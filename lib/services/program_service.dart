import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/program.dart';

class ProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RadioProgram>> getLivePrograms() {
    return _firestore
        .collection('programs')
        .where('isLive', isEqualTo: true)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RadioProgram.fromFirestore(doc)).toList();
    });
  }

  Stream<List<RadioProgram>> getTodayPrograms() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _firestore
        .collection('programs')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('startTime', isLessThan: Timestamp.fromDate(tomorrow))
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RadioProgram.fromFirestore(doc)).toList();
    });
  }

  Stream<List<RadioProgram>> getUpcomingPrograms() {
    final now = DateTime.now();
    return _firestore
        .collection('programs')
        .where('startTime', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('startTime')
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RadioProgram.fromFirestore(doc)).toList();
    });
  }

  Stream<List<RadioProgram>> getPodcasts() {
    return _firestore
        .collection('programs')
        .where('isPodcast', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RadioProgram.fromFirestore(doc)).toList();
    });
  }

  Stream<RadioProgram?> getCurrentProgram() {
    final now = Timestamp.now();

    return _firestore
        .collection('programs')
        .where('startTime', isLessThanOrEqualTo: now)
        .where('endTime', isGreaterThan: now)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return RadioProgram.fromFirestore(snapshot.docs.first);
    });
  }

  Future<RadioProgram?> getCurrentProgramFuture() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('programs')
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('isLive', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return RadioProgram.fromFirestore(snapshot.docs.first);
  }
}
