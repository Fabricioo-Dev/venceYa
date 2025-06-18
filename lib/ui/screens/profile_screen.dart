// lib/ui/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/models/user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  /// Carga los datos del usuario actual al iniciar la pantalla.
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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
      _errorMessage = "Error al cargar datos del perfil: $e";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Cierra la sesión del usuario.
  Future<void> _signOut() async {
    try {
      final authService = context.read<AuthService>();
      await authService.signOut();
      // GoRouter se encargará de la redirección al login.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'), // <<-- VUELVE AL DASHBOARD
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: AppTheme.categoryRed)))
              : _userData == null
                  ? const Center(
                      child: Text(
                        'No se encontraron datos de usuario. Intenta iniciar sesión de nuevo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textMedium),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                AppTheme.primaryBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.person_outline,
                              size: 70,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${_userData!.firstName ?? ''} ${_userData!.lastName ?? ''}'
                                    .trim()
                                    .isEmpty
                                ? (_userData!.displayName ?? 'Usuario')
                                    .split(' ')[0]
                                : '${_userData!.firstName ?? ''} ${_userData!.lastName ?? ''}'
                                    .trim(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(color: AppTheme.textDark),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _userData!.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: AppTheme.textMedium),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/dashboard');
                            },
                            icon:
                                const Icon(Icons.list_alt, color: Colors.white),
                            label: const Text('Ver Mis Recordatorios'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout,
                                color: AppTheme.categoryRed),
                            label: const Text('Cerrar Sesión'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.categoryRed,
                              side:
                                  const BorderSide(color: AppTheme.categoryRed),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
