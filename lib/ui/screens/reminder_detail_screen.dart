// lib/ui/screens/reminder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';

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
    if (!_isLoading) {
      setState(() => _isLoading = true);
    }
    try {
      final reminderData = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId);
      if (mounted) {
        setState(() {
          _reminder = reminderData;
          _errorMessage = reminderData == null
              ? "El recordatorio no fue encontrado."
              : null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Error al cargar los datos.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReminder() async {
    final bool? confirmed = await _showDeleteConfirmationDialog();
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await context.read<FirestoreService>().deleteReminder(widget.reminderId);
      await context
          .read<LocalNotificationService>()
          .cancelNotification(widget.reminderId.hashCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Recordatorio eliminado'),
            backgroundColor: AppTheme.categoryGreen));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Error al eliminar el recordatorio.'),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determina si el recordatorio está vencido aquí para usarlo en la UI.
    final bool isOverdue = _reminder?.dueDate.isBefore(DateTime.now()) ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_reminder?.title ?? 'Detalle'),
        actions: [
          if (_reminder != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              // Si el recordatorio está vencido (`isOverdue`), `onPressed`
              // es `null`, lo que deshabilita el botón automáticamente.
              // En caso contrario, permite la navegación.
              onPressed: isOverdue
                  ? null
                  : () => context.pushNamed(
                        'editReminder',
                        pathParameters: {'id': _reminder!.id!},
                      ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              tooltip: 'Eliminar',
              onPressed: _deleteReminder,
            ),
          ]
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_reminder == null) {
      return const Center(child: Text('El recordatorio ya no existe.'));
    }
    return _buildReminderDetails(_reminder!);
  }

  Widget _buildReminderDetails(Reminder reminder) {
    return RefreshIndicator(
      onRefresh: _loadReminder,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          if (reminder.dueDate.isBefore(DateTime.now())) _buildOverdueBanner(),
          _buildDetailItem('Título', reminder.title),
          if (reminder.description?.isNotEmpty ?? false)
            _buildDetailItem('Descripción', reminder.description!),
          _buildDetailItem('Vence el',
              DateFormat.yMMMMEEEEd('es').add_jm().format(reminder.dueDate)),
          _buildDetailItem('Categoría', _getCategoryText(reminder.category)),
          _buildDetailItem('Notificación',
              reminder.isNotificationEnabled ? 'Activada' : 'Desactivada'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(thickness: 0.5, height: 16),
        ],
      ),
    );
  }

  Widget _buildOverdueBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          const Expanded(child: Text('Este recordatorio ha vencido.')),
        ],
      ),
    );
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
}
