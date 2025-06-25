import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para acceder a los metadatos del usuario
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/core/theme.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Importar para usar Timer

// --- DEFINICIÓN DEL WIDGET ---
// DashboardScreen es un "Widget Dinámico" (StatefulWidget) porque necesita
// manejar un `TabController` para las pestañas, el cual debe ser creado y destruido.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer?
      _timer; // Declaración del temporizador para actualizaciones de UI basadas en el tiempo

  // --- CICLO DE VIDA ---

  // `initState` se ejecuta una sola vez cuando el widget se crea.
  @override
  void initState() {
    super.initState();
    // Inicializa el controlador de pestañas.
    _tabController = TabController(length: 3, vsync: this);
    // Actualiza la fecha del último login.
    _updateLastLogin();
    // Revisa si el usuario es nuevo para mostrar el mensaje de bienvenida.
    _checkIfNewUserAndShowMessage();

    // Configura un temporizador que se dispara periódicamente (cada 10 segundos)
    // para forzar la reconstrucción del widget y reevaluar los recordatorios vencidos.
    // He reducido el intervalo a 10 segundos para una respuesta visual más rápida.
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        // Asegura que el widget sigue montado antes de llamar a setState
        setState(() {
          // Un setState vacío es suficiente para forzar la re-evaluación y ver si un recordatorio ya vencio
        });
      }
    });
  }

  // `dispose` se ejecuta cuando el widget se destruye para liberar recursos.
  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel(); // Cancela el temporizador para evitar fugas de memoria
    super.dispose();
  }

  // --- LÓGICA DE LA PANTALLA ---

  void _checkIfNewUserAndShowMessage() {
    // Obtenemos el usuario actual directamente de FirebaseAuth.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // `user.metadata.creationTime` nos da la fecha y hora exactas de creación de la cuenta.
    final creationTime = user.metadata.creationTime;

    if (creationTime != null &&
        DateTime.now().difference(creationTime).inSeconds < 5) {
      // Usamos `addPostFrameCallback` para mostrar el SnackBar de forma segura
      // después de que la pantalla se haya dibujado por completo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                      "¡Cuenta creada con éxito!"),
                ],
              ),
              backgroundColor: AppTheme.categoryGreen,
            ),
          );
        }
      });
    }
    
  }

  /// Actualiza la fecha del último inicio de sesión del usuario en Firestore.
  Future<void> _updateLastLogin() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = authService.getCurrentUser();

    if (currentUser != null) {
      await firestoreService
          .updateUserData(currentUser.uid, {'lastLogin': DateTime.now()});
    }
  }

  // --- MÉTODOS AYUDANTES PARA CONSTRUIR LA UI ---

  /// Construye la lista visual de recordatorios.
  Widget _buildReminderList(List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return const Center(
        child: Text(
          'No hay recordatorios en esta categoría.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppTheme.textMedium),
        ),
      );
    }

    // `ListView.builder` es el widget más eficiente para mostrar listas.
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        // Comprueba si el recordatorio ha vencido comparando con la hora actual
        final bool isOverdue = reminder.dueDate.isBefore(DateTime.now());

        // `Card` y `ListTile` para cada fila de la lista.
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(reminder.category),
              child: Icon(_getCategoryIcon(reminder.category),
                  color: Colors.white),
            ),
            title: Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // El texto de la fecha cambia de color si el recordatorio ha vencido
                  'Vence: ${DateFormat.yMMMd('es').add_jm().format(reminder.dueDate)}',
                  style: TextStyle(
                    color:
                        isOverdue ? AppTheme.categoryRed : AppTheme.textMedium,
                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text('Categoría: ${_getCategoryText(reminder.category)}'),
              ],
            ),
            isThreeLine: true,
            trailing: reminder.isNotificationEnabled
                ? const Icon(Icons.notifications_active,
                    color: AppTheme.accentBlue)
                : const Icon(Icons.notifications_off,
                    color: AppTheme.textMedium),
            onTap: () {
              context.goNamed('reminderDetail',
                  pathParameters: {'id': reminder.id!});
            },
          ),
        );
      },
    );
  }

  /// Devuelve un color basado en la categoría del recordatorio.
  Color _getCategoryColor(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.payments:
        return AppTheme.categoryRed;
      case ReminderCategory.services:
        return AppTheme.categoryBlue;
      case ReminderCategory.documents:
        return AppTheme.categoryGreen;
      case ReminderCategory.personal:
        return AppTheme.categoryPurple;
      case ReminderCategory.other:
        return AppTheme.categoryLightGrey;
    }
  }

  /// Devuelve un ícono basado en la categoría del recordatorio.
  IconData _getCategoryIcon(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.payments:
        return Icons.account_balance_wallet_outlined;
      case ReminderCategory.services:
        return Icons.build_outlined;
      case ReminderCategory.documents:
        return Icons.description_outlined;
      case ReminderCategory.personal:
        return Icons.person_outline;
      case ReminderCategory.other:
        return Icons.category_outlined;
    }
  }

  /// Convierte el enum de Categoría a texto en español.
  String _getCategoryText(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.payments:
        return 'Pagos';
      case ReminderCategory.services:
        return 'Servicios';
      case ReminderCategory.documents:
        return 'Documentos';
      case ReminderCategory.personal:
        return 'Personal';
      case ReminderCategory.other:
        return 'Otro'; 
    }
  }

  // --- MÉTODO PRINCIPAL DE CONSTRUCCIÓN DE LA UI ---
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = authService.getCurrentUser();

    // `Scaffold` es el esqueleto básico de la pantalla.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
        // `TabBar` dibuja la barra de pestañas.
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Próximos'),
            Tab(text: 'Pasados'),
          ],
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Usuario no autenticado. Redirigiendo...'))
          // `StreamBuilder` se conecta a Firestore y se actualiza en tiempo real.
          : StreamBuilder<List<Reminder>>(
              stream: firestoreService.getRemindersStream(currentUser.uid),
              builder: (context, snapshot) {
                // Muestra un cargador mientras espera los datos.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Muestra un error si la conexión falla.
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error al cargar datos: ${snapshot.error}'));
                }

                final allReminders = snapshot.data ?? [];

                if (allReminders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes recordatorios aún.\n¡Añade uno con el botón +!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, color: AppTheme.textMedium),
                    ),
                  );
                }

                // `TabBarView` muestra el contenido de la pestaña activa.
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReminderList(allReminders), // Pestaña "Todos"
                    _buildReminderList(// Pestaña "Próximos"
                        allReminders
                            .where((r) => !r.dueDate.isBefore(DateTime.now()))
                            .toList()),
                    _buildReminderList(// Pestaña "Pasados"
                        allReminders
                            .where((r) => r.dueDate.isBefore(DateTime.now()))
                            .toList()),
                  ],
                );
              },
            ),
      // `FloatingActionButton` es el botón circular "flotante".
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add-reminder');
        },
        tooltip: 'Añadir Recordatorio',
        child: const Icon(Icons.add),
      ),
    );
  }
}
