// lib/ui/screens/login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/models/user_data.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';

/// Bloque Principal: `LoginScreen Widget`.
///
/// Es `StatefulWidget` porque necesita gestionar el estado del formulario,
/// como los valores de los campos de texto, si la contraseña es visible,
/// el estado de carga y los mensajes de error.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Bloque de Estado: `_LoginScreenState`.
///
/// Contiene toda la lógica y las variables que pueden cambiar mientras el
/// usuario interactúa con la pantalla.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Bloque de Lógica: `_signInWithEmail`.
  ///
  /// Orquesta el proceso de inicio de sesión con correo y contraseña.
  Future<void> _signInWithEmail() async {
    // 1. Valida el formulario. Si no es válido, la función se detiene.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2. Inicia el estado de carga.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 3. Llama al servicio para realizar la autenticación.
      await context.read<AuthService>().signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Si tiene éxito, GoRouter se encargará de la redirección.
    } on FirebaseAuthException {
      // 4. Captura errores específicos de Firebase para dar feedback claro.
      setState(() {
        _errorMessage = "Credenciales incorrectas o usuario no existente.";
      });
    } catch (e) {
      // 5. Captura cualquier otro error.
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Inténtalo de nuevo.";
      });
    } finally {
      // 6. Se asegura de detener el estado de carga, incluso si hubo un error.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bloque de Lógica: `_signInWithGoogle`.
  ///
  /// Gestiona el flujo de inicio de sesión con Google, incluyendo la creación
  /// del perfil de usuario en Firestore si es la primera vez que inicia sesión.
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final userCredential = await authService.signInWithGoogle();

      // Si el usuario cancela el pop-up de Google, userCredential será nulo.
      if (userCredential?.user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = userCredential!.user!;

      // Lógica clave: Revisa si es un usuario nuevo o uno que regresa.
      final existingUserData = await firestoreService.getUserData(user.uid);
      if (existingUserData == null) {
        // Si es nuevo, crea su perfil en Firestore.
        final names = user.displayName?.split(' ') ?? [''];
        await firestoreService.setUserData(
          UserData(
            uid: user.uid,
            email: user.email ?? '',
            firstName: names.first,
            lastName: names.length > 1 ? names.last : '',
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            photoUrl: user.photoURL,
          ),
        );
      } else {
        // Si ya existía, solo actualiza su fecha de último login.
        await firestoreService
            .updateUserData(user.uid, {'lastLogin': DateTime.now()});
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Error al iniciar sesión con Google. Inténtalo de nuevo.";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Bloque de Construcción de UI: `build`.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        automaticallyImplyLeading: false, // Oculta la flecha de 'atrás'
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Bienvenido de nuevo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Organiza tus vencimientos fácilmente.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppTheme.textMedium)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, ingresa tu correo.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Muestra el widget de error solo si `_errorMessage` no es nulo.
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14),
                        textAlign: TextAlign.center),
                  ),
                // Muestra el indicador de carga o los botones según el estado `_isLoading`.
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildAuthButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bloque de UI Helper: `_buildAuthButtons`.
  ///
  /// Construye los botones de acción para mantener el método `build` más limpio.
  /// Recibe el `BuildContext` para poder usarlo en la navegación.
  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _signInWithEmail,
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¿No tienes una cuenta?"),
            TextButton(
              /// Posible pregunta: ¿Por qué `push` y no `go`?
              /// Respuesta: "Uso `push` para que la pantalla de registro se apile
              /// encima de la de login. Esto mantiene el historial de navegación
              /// y hace que Flutter muestre automáticamente una flecha para
              /// volver (`pop`) a la pantalla anterior, que es el comportamiento
              /// esperado por el usuario."
              onPressed: () => context.push('/signup'),
              child: const Text('Regístrate'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("O")),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: Image.asset('assets/google_logo.png', height: 22.0),
          label: const Text('Continuar con Google'),
          onPressed: _signInWithGoogle,
          style: ElevatedButton.styleFrom(
            foregroundColor: AppTheme.textDark,
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
