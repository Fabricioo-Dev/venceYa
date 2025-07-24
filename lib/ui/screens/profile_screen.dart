// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/models/user_data.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';

/// Bloque Principal: `ProfileScreen Widget`.
///
/// Muestra la información del perfil del usuario y ofrece acciones como
/// navegar al dashboard o cerrar sesión. Es `StatefulWidget` porque su
/// contenido depende de datos que se cargan de forma asíncrona.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Bloque de Estado: `_ProfileScreenState`.
///
/// Contiene la lógica para cargar los datos del usuario, manejar los estados
/// de la UI y construir la interfaz visual correspondiente.
class _ProfileScreenState extends State<ProfileScreen> {
  UserData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Bloque de Lógica de Datos: `_loadUserData`.
  ///
  /// Se comunica con los servicios para obtener los datos del usuario actual,
  /// maneja los posibles errores y actualiza el estado de la pantalla.
  Future<void> _loadUserData() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception("Usuario no autenticado.");
      }

      final userDataFromDb =
          await firestoreService.getUserData(currentUser.uid);
      if (mounted) {
        setState(() {
          _userData = userDataFromDb;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar el perfil.";
          _isLoading = false;
        });
      }
    }
  }

  /// Bloque de Lógica de Autenticación: `_signOut`.
  ///
  /// Llama al servicio de autenticación para cerrar la sesión del usuario.
  Future<void> _signOut() async {
    await context.read<AuthService>().signOut();
  }

  /// Bloque de Construcción Principal: `build`.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  /// Bloque de UI Helper: `_buildBody`.
  ///
  /// Decide qué widget mostrar basado en el estado actual: un indicador
  /// de carga, un mensaje de error o la vista del perfil.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_userData == null) {
      return const Center(child: Text('No se encontraron datos de usuario.'));
    }
    return _buildProfileView(_userData!);
  }

  /// Bloque de UI Helper: `_buildProfileView`.
  ///
  /// Construye la vista principal del perfil una vez que los datos se han cargado.
  Widget _buildProfileView(UserData user) {
    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: <Widget>[
          _buildAvatar(user),
          const SizedBox(height: 16),
          Text(
            _getUserDisplayName(user),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // --- BOTÓN AÑADIDO ---
          // Este botón ofrece una navegación clara hacia la pantalla principal.
          ElevatedButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.list_alt_outlined),
            label: const Text('Ver Mis Recordatorios'),
            style: ElevatedButton.styleFrom(
              // Usamos el color de acento del tema para consistencia visual.
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // --- Botón de Cerrar Sesión ---
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Bloque de UI Helper: `_buildAvatar`.
  ///
  /// Construye el avatar del usuario, mostrando su foto o un ícono por defecto.
  Widget _buildAvatar(UserData user) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppTheme.primaryBlue..withAlpha(26),
      backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
      child: !hasPhoto
          ? const Icon(
              Icons.person_outline,
              size: 70,
              color: AppTheme.primaryBlue,
            )
          : null,
    );
  }

  /// Bloque de Lógica Helper: `_getUserDisplayName`.
  ///
  /// Determina qué nombre mostrar con una lógica de prioridades.
  String _getUserDisplayName(UserData user) {
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (user.displayName?.isNotEmpty ?? false) {
      return user.displayName!;
    }
    return user.email.split('@').first;
  }
}
