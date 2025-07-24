// lib/ui/screens/signup_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/models/user_data.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';

/// Bloque Principal: `SignUpScreen Widget`.
///
/// Es la pantalla para el registro de nuevos usuarios. Se define como `StatefulWidget`
/// porque debe gestionar un estado complejo: los valores de múltiples campos de
/// texto, las validaciones del formulario, la visibilidad de las contraseñas y el
/// estado de carga (`_isLoading`) durante el proceso de registro.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

/// Bloque de Estado: `_SignUpScreenState`.
///
/// Esta clase contiene toda la lógica y las variables que pueden cambiar mientras el
/// usuario interactúa con la pantalla de registro.
class _SignUpScreenState extends State<SignUpScreen> {
  // Clave global para identificar y gestionar el estado del Form.
  final _formKey = GlobalKey<FormState>();
  // Controladores para cada campo de texto. Nos permiten leer y manipular su contenido.
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Variables de estado que controlan la apariencia y el comportamiento de la UI.
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  /// Bloque de Ciclo de Vida: `dispose`.
  ///
  /// Este método es fundamental. Se llama automáticamente cuando la pantalla
  /// se destruye. Aquí debemos limpiar (hacer `dispose`) de todos los
  /// controladores para liberar los recursos que ocupan en memoria y
  /// prevenir errores conocidos como "memory leaks".
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Bloque de Lógica Principal: `_signUp`.
  ///
  /// Orquesta todo el proceso de registro, desde la validación del formulario
  /// hasta la creación del usuario en Firebase y Firestore.
  Future<void> _signUp() async {
    // 1. Validar el formulario. Si `validate()` devuelve `false`, la función se detiene.
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Iniciar el estado de carga y limpiar errores previos.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();

      // 3. Crear el usuario en Firebase Authentication.
      final userCredential = await authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('No se pudo obtener el usuario recién creado.');
      }

      // 4. Crear el documento del usuario en Firestore con sus datos adicionales.
      await firestoreService.setUserData(
        UserData(
          uid: user.uid,
          email: user.email ?? '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        ),
      );

      // 5. Navegar de vuelta al Login después de un registro exitoso.
      // Posible pregunta: ¿Por qué no navegas directo al Dashboard?
      // Respuesta: "Por seguridad y para confirmar el flujo, después del registro
      // redirigimos al usuario al login para que inicie sesión con sus nuevas
      // credenciales. Esto confirma que todo el proceso funcionó correctamente."
      if (mounted) {
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      // 6. Manejo de errores específicos de Firebase para dar feedback claro.
      setState(() {
        _errorMessage = _getFirebaseAuthErrorMessage(e);
      });
    } catch (e) {
      // 7. Manejo de cualquier otro error inesperado.
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      });
    } finally {
      // 8. Asegurarse de que el indicador de carga se oculte, incluso si hubo un error.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bloque de Lógica Helper: `_getFirebaseAuthErrorMessage`.
  ///
  /// Una función de ayuda que traduce los códigos de error técnicos de Firebase
  /// a mensajes legibles para el usuario. Esto mantiene la lógica de `_signUp` más limpia.
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      default:
        return 'Ocurrió un error durante el registro.';
    }
  }

  /// Bloque de Construcción de UI: `build`.
  ///
  /// Dibuja la pantalla completa. Es declarativo, mostrando qué widgets deben
  /// aparecer basados en el estado actual (`_isLoading`, `_errorMessage`, etc.).
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        // Posible pregunta: ¿Cómo funciona la flecha para volver atrás?
        // Respuesta: "No necesitamos un botón `leading` personalizado. Como
        // navegamos a esta pantalla desde el Login (`context.go('/signup')`),
        // GoRouter la pone "encima" en la pila de navegación. El `AppBar` de
        // Flutter detecta esto automáticamente y añade el botón de 'atrás'
        // que ejecuta `context.pop()` por nosotros."
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Completa tus datos para registrarte',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),

                // --- Campos del Formulario ---
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return 'Ingresa tu nombre.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return 'Ingresa tu apellido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (val) {
                    if (val?.trim().isEmpty ?? true) {
                      return 'Ingresa tu correo.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val!)) {
                      return 'Ingresa un correo válido.';
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
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (val) {
                    if (val?.isEmpty ?? true) {
                      return 'Ingresa tu contraseña.';
                    }
                    if (val!.length < 6) {
                      return 'Mínimo 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(() =>
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible),
                    ),
                  ),
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Las contraseñas no coinciden.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- Feedback al Usuario ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('Registrarse'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
