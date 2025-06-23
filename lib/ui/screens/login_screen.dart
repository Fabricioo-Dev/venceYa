// lib/ui/screens/login_screen.dart

// --- IMPORTACIONES ESENCIALES ---
// Importa el paquete fundamental de Flutter para construir la interfaz de usuario con widgets de Material Design.
import 'package:flutter/material.dart';

// Importa Provider para acceder a nuestros servicios (como AuthService) de forma ordenada.
import 'package:provider/provider.dart';

// Importa GoRouter para manejar la navegación entre pantallas.
import 'package:go_router/go_router.dart';

// Importa la excepción específica de Firebase Auth para poder capturar errores de autenticación.
import 'package:firebase_auth/firebase_auth.dart';

// Importa nuestros servicios y modelos locales. Estas son las rutas correctas.
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/models/user_data.dart';
import 'package:venceya/core/theme.dart';

// --- DEFINICIÓN DEL WIDGET ---
// LoginScreen es un "Widget Dinámico" (StatefulWidget) porque su contenido necesita cambiar
// en respuesta a la interacción del usuario (texto en los campos, estado de carga, errores).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// --- CLASE DE ESTADO DEL WIDGET ---
class _LoginScreenState extends State<LoginScreen> {
  // --- VARIABLES DE ESTADO ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Es CRUCIAL "limpiar" los controladores para evitar fugas de memoria.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Gestiona el proceso de inicio de sesión con correo electrónico y contraseña.
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthService>().signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } on FirebaseAuthException {
      setState(() {
        _errorMessage = "Error: Credenciales incorrectas o usuario no existe.";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Gestiona el proceso de inicio de sesión con una cuenta de Google.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();

      final userCredential = await authService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        throw Exception("El inicio de sesión con Google fue cancelado.");
      }

      final user = userCredential.user!;
      final existingUserData = await firestoreService.getUserData(user.uid);

      if (existingUserData == null) {
        // Si es la PRIMERA VEZ que inicia sesión, creamos su registro en Firestore.
        await firestoreService.setUserData(
          UserData(
            uid: user.uid,
            email: user.email ?? '',
            firstName: user.displayName?.split(' ').first ?? '',
            lastName: user.displayName?.split(' ').lastOrNull ?? '',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          ),
        );
      } else {
        // Si ya existía, solo actualizamos su fecha de último inicio de sesión.
        await firestoreService
            .updateUserData(user.uid, {'lastLogin': DateTime.now()});
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error con Google Sign-In: Revisa tu conexión.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión para continuar organizando tus vencimientos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa tu correo electrónico';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppTheme.textMedium,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.categoryRed, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Iniciar Sesión',
                                style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("¿No tienes una cuenta?"),
                              TextButton(
                                onPressed: () {
                                  context.go('/signup');
                                },
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Row(
                            children: <Widget>[
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text("O"),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Image.asset('assets/google_logo.png',
                                height: 24.0),
                            label: const Text('Continuar con Google'),
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
