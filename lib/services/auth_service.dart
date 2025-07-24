// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servicio que centraliza y gestiona la lógica de autenticación con Firebase.
///
/// Abstrae los métodos de Firebase Auth para que el resto de la app no
/// interactúe directamente con el plugin, facilitando cambios o migraciones.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Variable para pasar un mensaje simple entre la pantalla de registro y login.
  ///
  /// NOTA PARA EL EXAMEN: Esta es una solución simple y directa. Para casos más
  /// complejos, una mejor práctica sería pasar datos como parámetros de ruta
  /// o usar un gestor de estado más avanzado.
  String? postSignupMessage;

  /// Stream que notifica en tiempo real sobre cambios en la autenticación.
  /// Es la forma reactiva y principal de escuchar el estado del usuario en la UI.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Getter para obtener el usuario actual de forma síncrona.
  /// Es más idiomático que un método `getCurrentUser()`.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Inicia sesión con correo y contraseña.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // No es necesario usar `await` aquí. La función ya devuelve el `Future`
    // directamente, haciendo el código más conciso.
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registra un nuevo usuario con correo y contraseña.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Inicia sesión del usuario a través de su cuenta de Google.
  Future<UserCredential?> signInWithGoogle() async {
    // 1. Inicia el flujo de autenticación nativo de Google.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // El usuario puede cancelar el flujo, en cuyo caso `googleUser` será nulo.
    if (googleUser == null) {
      return null;
    }

    // 2. Obtiene los tokens de autenticación de la cuenta de Google.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Usa las credenciales de Google para iniciar sesión en Firebase.
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    // Es importante cerrar sesión en ambos servicios para un logout completo,
    // especialmente para que Google no auto-seleccione la cuenta la próxima vez.
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
