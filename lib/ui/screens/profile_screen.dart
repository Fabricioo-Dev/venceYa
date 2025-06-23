// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import necesario para la navegación.
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/models/user_data.dart';

// --- DEFINICIÓN DEL WIDGET ---
// ProfileScreen es un "Widget Dinámico" (StatefulWidget) porque necesita
// cargar los datos del perfil del usuario de forma asíncrona y manejar
// un estado de carga mientras lo hace.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// --- CLASE DE ESTADO DEL WIDGET ---
class _ProfileScreenState extends State<ProfileScreen> {
  // --- VARIABLES DE ESTADO ---
  UserData? _userData; // Almacenará los datos del perfil una vez cargados.
  bool _isLoading = true; // Controla el indicador de carga.
  String? _errorMessage; // Almacena mensajes de error.

  // --- CICLO DE VIDA ---
  @override
  void initState() {
    super.initState();
    // Inicia la carga de datos en cuanto la pantalla se crea.
    _loadUserData();
  }

  // --- LÓGICA DE DATOS ---

  /// Obtiene los datos del perfil del usuario logueado desde Firestore.
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final currentUser = authService.getCurrentUser();

      if (currentUser != null) {
        _userData = await firestoreService.getUserData(currentUser.uid);
      } else {
        _errorMessage = "Usuario no autenticado.";
      }
    } catch (e) {
      _errorMessage = "Error al cargar datos del perfil: ${e.toString()}";
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Cierra la sesión del usuario a través del AuthService.
  Future<void> _signOut() async {
    try {
      // La navegación a la pantalla de login la maneja el listener
      // del stream de autenticación, no es necesario hacerla aquí.
      await context.read<AuthService>().signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  // --- GETTERS Y HELPERS DE UI ---

  /// Una propiedad computada (`getter`) que devuelve el nombre a mostrar del usuario.
  /// Encapsular esta lógica aquí hace que el widget `Text` en el `build` sea muy simple.
  String get _userName {
    if (_userData == null) return 'Usuario';

    // 1. Intenta usar el nombre y apellido del registro manual.
    final manualName =
        '${_userData!.firstName ?? ''} ${_userData!.lastName ?? ''}'.trim();
    if (manualName.isNotEmpty) {
      return manualName;
    }

    // 2. Si no hay nombre manual, usa el nombre de la cuenta social (ej. Google).
    if (_userData!.displayName != null && _userData!.displayName!.isNotEmpty) {
      return _userData!.displayName!;
    }

    // 3. Como último recurso, muestra la parte del email antes del @.
    return _userData!.email.split('@').first;
  }

  /// Construye el cuerpo principal de la pantalla según el estado actual.
  /// Esto evita tener condicionales ternarios anidados y complejos en el método `build`.
  Widget _buildBody() {
    // 1. Si está cargando, muestra el indicador.
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. Si hay un error, lo muestra.
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!,
              style: const TextStyle(color: AppTheme.categoryRed)));
    }
    // 3. Si no hay datos de usuario, muestra un mensaje informativo.
    if (_userData == null) {
      return const Center(child: Text('No se encontraron datos de usuario.'));
    }

    // 4. Si todo está bien, construye la vista del perfil.
    return RefreshIndicator(
      onRefresh:
          _loadUserData, // Permite refrescar los datos deslizando hacia abajo.
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Avatar dinámico: muestra la foto de perfil si existe, si no, un ícono.
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryBlue.withAlpha(26),
                // El backgroundImage intentará cargar la imagen de la red.
                backgroundImage: (_userData!.photoUrl != null &&
                        _userData!.photoUrl!.isNotEmpty)
                    ? NetworkImage(_userData!.photoUrl!)
                    : null,
                // El child (el ícono) solo se mostrará si backgroundImage es nulo.
                child: (_userData!.photoUrl == null ||
                        _userData!.photoUrl!.isEmpty)
                    ? const Icon(
                        Icons.person_outline,
                        size: 70,
                        color: AppTheme.primaryBlue,
                      )
                    : null,
              ),
              const SizedBox(height: 24),

              // Muestra el nombre del usuario usando nuestro getter limpio.
              Text(
                _userName,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Muestra el correo electrónico del usuario.
              Text(
                _userData!.email,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppTheme.textMedium),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- BOTÓN AÑADIDO ---
              // Botón para ir al Dashboard de recordatorios.
              ElevatedButton.icon(
                onPressed: () => context.go('/dashboard'),
                icon: const Icon(Icons.list_alt),
                label: const Text('Ver Mis Recordatorios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para cerrar sesión.
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.categoryRed,
                  side: const BorderSide(color: AppTheme.categoryRed),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODO PRINCIPAL DE CONSTRUCCIÓN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      // El cuerpo del Scaffold simplemente llama a nuestro método ayudante.
      body: _buildBody(),
    );
  }
}
