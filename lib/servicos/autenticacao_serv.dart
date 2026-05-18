import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/usuario.dart';
import '../core/constants/app_constants.dart';

class AutenticacaoServ {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<Usuario> registar({
    required String nomeCompleto,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(nomeCompleto);

      final usuario = Usuario(
        uid: credential.user!.uid,
        nomeCompleto: nomeCompleto,
        email: email,
        criadoEm: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(usuario.uid)
          .set(usuario.toMap());

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<Usuario> entrar({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (doc.exists) {
        return Usuario.fromMap(doc.data()!);
      }

      return Usuario(
        uid: credential.user!.uid,
        nomeCompleto: credential.user!.displayName ?? '',
        email: email,
        criadoEm: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  Future<Usuario?> obterPerfil(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) return Usuario.fromMap(doc.data()!);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> atualizarPerfil(Usuario usuario) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(usuario.uid)
        .update(usuario.toMap());

    await _auth.currentUser?.updateDisplayName(usuario.nomeCompleto);
    if (usuario.fotoUrl != null) {
      await _auth.currentUser?.updatePhotoURL(usuario.fotoUrl);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-not-found':
        return 'Utilizador não encontrado.';
      case 'wrong-password':
        return 'Senha incorrecta.';
      case 'invalid-credential':
        return 'Email ou senha incorrectos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}