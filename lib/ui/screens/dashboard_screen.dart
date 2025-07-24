// lib/ui/screens/dashboard_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';

// La extensión para las propiedades de UI del enum es un excelente patrón.
extension ReminderCategoryDisplay on ReminderCategory {
  Color get color {
    switch (this) {
      case ReminderCategory.payments:
        return AppTheme.statusError;
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

  IconData get icon {
    switch (this) {
      case ReminderCategory.payments:
        return Icons.account_balance_wallet_outlined;
      case ReminderCategory.services:
        return Icons.miscellaneous_services_outlined;
      case ReminderCategory.documents:
        return Icons.description_outlined;
      case ReminderCategory.personal:
        return Icons.person_outline;
      case ReminderCategory.other:
        return Icons.category_outlined;
    }
  }

  String get displayText {
    switch (this) {
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
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _nextExpiryTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateLastLogin();
    _checkIfNewUserAndShowMessage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nextExpiryTimer?.cancel();
    super.dispose();
  }

  void _scheduleNextUpdate(List<Reminder> reminders) {
    _nextExpiryTimer?.cancel();
    final upcomingReminders =
        reminders.where((r) => r.dueDate.isAfter(DateTime.now())).toList();
    if (upcomingReminders.isEmpty) return;
    upcomingReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final nextReminderToExpire = upcomingReminders.first;
    final durationUntilExpiry =
        nextReminderToExpire.dueDate.difference(DateTime.now());
    _nextExpiryTimer = Timer(durationUntilExpiry, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recordatorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () => authService.signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Próximos'),
            Tab(text: 'Vencidos'),
          ],
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Usuario no encontrado.'))
          : StreamBuilder<List<Reminder>>(
              stream: firestoreService.getRemindersStream(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final allReminders = snapshot.data ?? [];
                if (allReminders.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes recordatorios aún.\n¡Añade uno para empezar!',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, color: AppTheme.textMedium),
                    ),
                  );
                }

                _scheduleNextUpdate(allReminders);

                final now = DateTime.now();
                final upcomingReminders = allReminders
                    .where((r) => !r.dueDate.isBefore(now))
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
                final overdueReminders = allReminders
                    .where((r) => r.dueDate.isBefore(now))
                    .toList()
                  ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReminderList(context, allReminders),
                    _buildReminderList(context, upcomingReminders),
                    _buildReminderList(context, overdueReminders),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        // Al usar `push` en lugar de `go`, la pantalla de "Añadir" se apila
        // sobre el Dashboard, conservando el historial y permitiendo volver.
        onPressed: () => context.push('/add-reminder'),
        tooltip: 'Añadir Recordatorio',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderList(BuildContext context, List<Reminder> reminders) {
    if (reminders.isEmpty) {
      return const Center(
        child: Text(
          'No hay recordatorios aquí.',
          style: TextStyle(fontSize: 16, color: AppTheme.textMedium),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final bool isOverdue = reminder.dueDate.isBefore(DateTime.now());

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: reminder.category.color,
              child: Icon(reminder.category.icon, color: Colors.white),
            ),
            title: Text(
              reminder.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              'Vence: ${DateFormat.yMMMEd('es').add_jm().format(reminder.dueDate)}',
              style: TextStyle(
                color: isOverdue
                    ? Theme.of(context).colorScheme.error
                    : AppTheme.textMedium,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: reminder.isNotificationEnabled
                ? const Icon(Icons.notifications_active,
                    color: AppTheme.accentBlue)
                : const Icon(Icons.notifications_off,
                    color: AppTheme.textMedium),
            onTap: () => context.pushNamed('reminderDetail',
                pathParameters: {'id': reminder.id!}),
          ),
        );
      },
    );
  }

  void _checkIfNewUserAndShowMessage() {
    final user = context.read<AuthService>().currentUser;
    if (user == null || user.metadata.creationTime == null) return;
    final creationTime = user.metadata.creationTime!;
    if (DateTime.now().difference(creationTime).inSeconds < 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text("¡Cuenta creada con éxito!"),
            ]),
            backgroundColor: AppTheme.categoryGreen,
          ));
        }
      });
    }
  }

  void _updateLastLogin() {
    final authService = context.read<AuthService>();
    if (authService.currentUser != null) {
      context.read<FirestoreService>().updateUserData(
          authService.currentUser!.uid, {'lastLogin': DateTime.now()});
    }
  }
}
