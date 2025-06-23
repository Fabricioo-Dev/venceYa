// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servicio para manejar toda la lógica de autenticación con Firebase.
class AuthService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- VARIABLE "MENSAJERA" ---
  /// Guarda un mensaje temporalmente después del registro para mostrarlo en otra pantalla.
  String? postSignupMessage;

  /// Un stream que notifica los cambios en el estado de autenticación (login/logout).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Devuelve el usuario actualmente logueado.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Inicia sesión con correo y contraseña.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registra un nuevo usuario con correo y contraseña.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Al tener éxito, Firebase inicia sesión automáticamente y dispara `authStateChanges`.
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Inicia sesión usando una cuenta de Google.
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null; // El usuario canceló el flujo.
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Cierra la sesión del usuario.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Devuelve `true` si hay un usuario logueado.
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}
