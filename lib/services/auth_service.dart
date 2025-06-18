// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService(this._firebaseAuth, this._googleSignIn);

  /// Stream para escuchar cambios en el estado de autenticación.
  /// Emite un objeto User si está autenticado, o null si no.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Obtiene el usuario actualmente autenticado.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Iniciar sesión con correo electrónico y contraseña.
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error en signInWithEmailAndPassword: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Registrar un nuevo usuario con correo electrónico y contraseña.
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error en signUpWithEmailAndPassword: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Iniciar sesión con Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in flow
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Error en signInWithGoogle: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error inesperado en signInWithGoogle: $e');
      throw Exception(
          'Error inesperado durante el inicio de sesión con Google.');
    }
  }

  /// Cerrar sesión.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Desloguearse de Google primero
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error en signOut: $e');
      throw Exception('Error al cerrar sesión.');
    }
  }

  /// Envía un correo electrónico para restablecer la contraseña a la dirección proporcionada.
  // ESTE ES EL MÉTODO QUE FALTABA Y QUE ES NECESARIO
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Error en sendPasswordResetEmail: ${e.code} - ${e.message}');
      rethrow; // Propaga la excepción para que la UI la maneje.
    } catch (e) {
      print('Error inesperado en sendPasswordResetEmail: $e');
      throw Exception('Error inesperado al enviar correo de restablecimiento.');
    }
  }
}
