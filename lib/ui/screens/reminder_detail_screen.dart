// lib/ui/screens/reminder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/core/theme.dart';

class ReminderDetailScreen extends StatefulWidget {
  final String reminderId;
  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  Reminder? _reminder;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reminder = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId);

      if (mounted) {
        setState(() {
          _reminder = reminder;
          if (reminder == null) {
            _errorMessage = "Recordatorio no encontrado o ya no existe.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al cargar el recordatorio: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReminder() async {
    if (_reminder == null) return;

  
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);
    final firestoreService = context.read<FirestoreService>();
    final localNotificationService = context.read<LocalNotificationService>();

    // `showDialog` crea un "async gap". Pausa la ejecución aquí.
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este recordatorio?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.categoryRed,
                foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    setState(() => _isLoading = true);

    try {
      // Usamos las referencias locales seguras que guardamos antes.
      await firestoreService.deleteReminder(_reminder!.id!);

      final notificationId = _reminder!.id!.hashCode & 0x7FFFFFFF;
      await localNotificationService.cancelNotification(notificationId);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Recordatorio eliminado con éxito.'),
          backgroundColor: AppTheme.categoryGreen,
        ),
      );

      // Usamos la referencia segura del navegador.
      navigator.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al eliminar: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppTheme.textMedium)),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(thickness: 1, height: 16),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _reminder == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.categoryRed, fontSize: 16)),
      ));
    }
    if (_reminder == null) {
      return const Center(child: Text('Recordatorio no disponible.'));
    }

    final bool isOverdue = _reminder!.dueDate.isBefore(DateTime.now());

    return RefreshIndicator(
      onRefresh: _loadReminder,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          if (isOverdue)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.categoryRed.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppTheme.categoryRed),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este recordatorio ha vencido. La edición está deshabilitada.',
                      style: TextStyle(color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),
          _buildDetailItem('Título:', _reminder!.title),
          if (_reminder!.description != null &&
              _reminder!.description!.isNotEmpty)
            _buildDetailItem('Descripción:', _reminder!.description!),
          _buildDetailItem('Vence el:',
              DateFormat.yMMMMEEEEd('es').add_jm().format(_reminder!.dueDate)),
          _buildDetailItem('Categoría:', _getCategoryText(_reminder!.category)),
          _buildDetailItem('Notificación Habilitada:',
              _reminder!.isNotificationEnabled ? 'Sí' : 'No'),
          if (_reminder!.createdAt != null)
            _buildDetailItem('Creado el:',
                DateFormat.yMMMd('es').add_jm().format(_reminder!.createdAt!)),
          if (_reminder!.updatedAt != null)
            _buildDetailItem('Última Actualización:',
                DateFormat.yMMMd('es').add_jm().format(_reminder!.updatedAt!)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = _reminder?.dueDate.isBefore(DateTime.now()) ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(_reminder?.title ?? 'Detalle'),
        actions: _reminder == null || _isLoading
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: isOverdue
                      ? 'No se puede editar un recordatorio vencido'
                      : 'Editar Recordatorio',
                  onPressed: isOverdue
                      ? null
                      : () => context.goNamed('editReminder',
                          pathParameters: {'id': _reminder!.id!}),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever,
                      color: AppTheme.categoryRed),
                  tooltip: 'Eliminar Recordatorio',
                  onPressed: _deleteReminder,
                ),
              ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading && _reminder != null) ...[
            const ModalBarrier(dismissible: false, color: Colors.black54),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
