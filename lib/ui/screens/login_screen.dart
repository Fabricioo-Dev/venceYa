// lib/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para FirebaseAuthException y UserCredential
import 'package:venceya/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp
import 'package:venceya/core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false; // Controla la visibilidad de la contraseña

  /// Inicia sesión con correo electrónico y contraseña.
  Future<void> _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await context.read<AuthService>().signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = "Error al iniciar sesión: ${e.message}";
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Error al iniciar sesión: ${e.toString()}";
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Inicia sesión con Google.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final userCredential =
          await context.read<AuthService>().signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        // Acceso seguro a user
        final firestoreService = context.read<FirestoreService>();
        final existingUserData = await firestoreService
            .getUserData(userCredential.user!.uid); // Acceso seguro a uid
        if (existingUserData == null) {
          await firestoreService.setUserData(
            UserData(
              uid: userCredential.user!.uid, // Acceso seguro a uid
              email: userCredential.user!.email ?? '', // Acceso seguro a email
              displayName:
                  userCredential.user!.displayName, // Propiedad de Firebase SDK
              photoUrl:
                  userCredential.user!.photoURL, // Propiedad de Firebase SDK
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            ),
          );
        } else {
          await firestoreService.updateUserData(userCredential.user!.uid,
              {'lastLogin': Timestamp.fromDate(DateTime.now())});
        }
      }
    } on FirebaseAuthException catch (e) {
      // Excepción de Firebase SDK
      setState(() {
        _errorMessage =
            "Error con Google Sign-In: ${e.message}"; // Mensaje de Firebase SDK
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error con Google Sign-In: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Inicia sesión para empezar',
                  style: TextStyle(fontSize: 18, color: AppTheme.textMedium),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Dirección Email',
                    hintText: 'Ingrese su Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                    hintText: 'Ingrese su contraseña',
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
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const SizedBox(
                    height:
                        24), // Espacio: botón "Contraseña olvidada?" eliminado.
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
                        children: [
                          ElevatedButton(
                            onPressed: _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Iniciar Sesión',
                                style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              context.go('/signup');
                            },
                            child: Text(
                              'Crear cuenta',
                              style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Inicia sesión con',
                            style: TextStyle(
                                fontSize: 16, color: AppTheme.textMedium),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _signInWithGoogle,
                                icon: Image.asset('assets/google_logo.png',
                                    height: 40),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(8.0),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(
                                        color: AppTheme.inputFillColor),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ],
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
