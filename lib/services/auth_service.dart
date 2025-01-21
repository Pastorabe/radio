import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Liste des emails admin
  static const List<String> adminEmails = [
    'yves.razafiharison@gmail.com',
    'radio.loterana@gmail.com'
  ];

  // Vérifier si un email est admin
  bool isEmailAdmin(String email) {
    return adminEmails.contains(email.trim().toLowerCase());
  }

  // Vérifier si l'utilisateur actuel est admin
  bool isCurrentUserAdmin() {
    final user = currentUser;
    return user != null && isEmailAdmin(user.email ?? '');
  }

  // Se connecter
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Nettoyer l'email
      final cleanEmail = email.trim().toLowerCase();
      
      // Vérifier si c'est un admin
      if (!isEmailAdmin(cleanEmail)) {
        throw 'Cet email n\'a pas les droits d\'administration.';
      }

      // Tentative de connexion
      await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      // Vérifier si la connexion a réussi
      final user = currentUser;
      if (user == null) {
        throw 'Erreur de connexion : utilisateur null après connexion.';
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Gérer les erreurs d'authentification
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'La connexion par email/mot de passe n\'est pas activée.';
      case 'network-request-failed':
        return 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
      case 'invalid-credential':
        return 'Les informations de connexion sont invalides.';
      default:
        return 'Erreur de connexion ($code). Veuillez réessayer.';
    }
  }
}
