// lib/ui/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/models/user_data.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/core/theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  UserData? _userData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Carga los datos del perfil del usuario desde Firestore.
  Future<void> _loadUserData() async {
    final authService = context.read<AuthService>();
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final currentUser = authService.getCurrentUser();

    if (currentUser != null) {
      UserData? fetchedUserData =
          await firestoreService.getUserData(currentUser.uid);

      if (fetchedUserData != null) {
        setState(() {
          _userData = fetchedUserData;
        });
        await firestoreService.updateUserData(
            currentUser.uid, {'lastLogin': Timestamp.fromDate(DateTime.now())});
      }
    }
  }

  /// Construye la lista de recordatorios.
  Widget _buildReminderList(List<Reminder> reminders, BuildContext context) {
    return ListView.builder(
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(reminder.category),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(reminder.category),
                color: Colors.white,
              ),
            ),
            title: Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vence: ${DateFormat.yMMMd('es').add_jm().format(reminder.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: reminder.dueDate.isBefore(DateTime.now())
                            ? AppTheme.categoryRed
                            : AppTheme.textMedium,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Categoría: ${_getCategoryText(reminder.category)}', // Categoría ahora en español
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: AppTheme.textMedium),
                ),
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
      default:
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
      default:
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
      default:
        return 'Otro';
    }
  }

  /// Convierte el enum de Frecuencia a texto en español.
  String _getFrequencyText(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.none:
        return 'Único';
      case ReminderFrequency.daily:
        return 'Diario';
      case ReminderFrequency.weekly:
        return 'Semanal';
      case ReminderFrequency.monthly:
        return 'Mensual';
      case ReminderFrequency.yearly:
        return 'Anual';
      default:
        return 'Único';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textDark),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryBlue,
              unselectedLabelColor: AppTheme.textMedium,
              indicatorColor: AppTheme.primaryBlue,
              labelStyle: Theme.of(context).textTheme.titleMedium,
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Próximos'),
                Tab(text: 'Pasados'),
              ],
            ),
          ),
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Usuario no autenticado. Redirigiendo...'))
          : TabBarView(
              controller: _tabController,
              children: [
                // Pestaña "Todos"
                StreamBuilder<List<Reminder>>(
                  stream: firestoreService.getRemindersStream(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error al cargar recordatorios: ${snapshot.error}',
                              style: const TextStyle(
                                  color: AppTheme.categoryRed)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes recordatorios aún. ¡Añade uno!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textMedium),
                        ),
                      );
                    }
                    return _buildReminderList(snapshot.data!, context);
                  },
                ),
                // Pestaña "Próximos"
                StreamBuilder<List<Reminder>>(
                  stream: firestoreService.getRemindersStream(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error al cargar recordatorios: ${snapshot.error}',
                              style: const TextStyle(
                                  color: AppTheme.categoryRed)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes recordatorios próximos. ¡Añade uno!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textMedium),
                        ),
                      );
                    }
                    final upcomingReminders = snapshot.data!
                        .where((r) => !r.dueDate.isBefore(DateTime.now()))
                        .toList();
                    if (upcomingReminders.isEmpty) {
                      return const Center(
                          child: Text('No tienes recordatorios próximos.'));
                    }
                    return _buildReminderList(upcomingReminders, context);
                  },
                ),
                // Pestaña "Pasados"
                StreamBuilder<List<Reminder>>(
                  stream: firestoreService.getRemindersStream(currentUser.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error al cargar recordatorios: ${snapshot.error}',
                              style: const TextStyle(
                                  color: AppTheme.categoryRed)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes recordatorios pasados. ¡Añade uno!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, color: AppTheme.textMedium),
                        ),
                      );
                    }
                    final pastReminders = snapshot.data!
                        .where((r) => r.dueDate.isBefore(DateTime.now()))
                        .toList();
                    if (pastReminders.isEmpty) {
                      return const Center(
                          child: Text('No tienes recordatorios pasados.'));
                    }
                    return _buildReminderList(pastReminders, context);
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add-reminder');
        },
        child: const Icon(Icons.add),
        tooltip: 'Añadir Recordatorio',
      ),
      // Se elimina la BottomNavigationBar de aquí, ya que la maneja MainShellScreen
    );
  }
}
