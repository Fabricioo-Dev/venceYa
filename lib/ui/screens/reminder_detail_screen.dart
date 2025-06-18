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
  bool _isLoading =
      true; // Indica si hay una operación de carga o eliminación en curso
  String? _errorMessage;

  /// Inicializa el estado y carga los detalles del recordatorio.
  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  /// Carga los detalles del recordatorio desde Firestore usando su ID.
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
      _errorMessage = "Error al cargar el recordatorio: $e";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Muestra un diálogo de confirmación y elimina el recordatorio de Firestore.
  Future<void> _deleteReminder() async {
    if (_reminder == null || _reminder!.id == null) return;

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este recordatorio?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            // Cambiado a ElevatedButton para el botón de eliminar en el diálogo
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.categoryRed,
                foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // Mostrar el indicador de carga y deshabilitar el botón inmediatamente.
      if (mounted) setState(() => _isLoading = true);
      try {
        await context.read<FirestoreService>().deleteReminder(_reminder!.id!);

        final notificationId = _reminder!.id!.hashCode & 0x7FFFFFFF;
        await context
            .read<LocalNotificationService>()
            .cancelNotification(notificationId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio eliminado.')),
        );
        // Navegar al Dashboard SÓLO después de la operación exitosa
        if (mounted) context.go('/dashboard');
      } on Exception catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Error al eliminar: ${e.toString()}";
          });
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_reminder?.title ?? 'Detalle del Recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : () =>
                  context.go('/dashboard'), // <<-- DESHABILITADO DURANTE CARGA
        ),
        actions: _reminder != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.textDark),
                  tooltip: 'Editar Recordatorio',
                  onPressed: _isLoading
                      ? null
                      : () {
                          // <<-- DESHABILITADO DURANTE CARGA
                          context.goNamed('editReminder',
                              pathParameters: {'id': _reminder!.id!});
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever,
                      color: AppTheme.categoryRed),
                  tooltip: 'Eliminar Recordatorio',
                  onPressed: _isLoading
                      ? null
                      : _deleteReminder, // <<-- DESHABILITADO DURANTE CARGA
                ),
              ]
            : null,
      ),
      body: Stack(
        // Usamos Stack para el overlay de carga al guardar
        children: [
          _isLoading &&
                  _reminder ==
                      null // Muestra el loading inicial o error si falla
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text(_errorMessage!,
                          style: const TextStyle(color: AppTheme.categoryRed)))
                  : _reminder == null
                      ? const Center(child: Text('Recordatorio no disponible.'))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView(
                            children: <Widget>[
                              _buildDetailItem('Título:', _reminder!.title),
                              _buildDetailItem(
                                  'Vence el:',
                                  DateFormat.yMMMd('es')
                                      .add_jm()
                                      .format(_reminder!.dueDate)),
                              _buildDetailItem('Categoría:',
                                  _getCategoryText(_reminder!.category)),
                              _buildDetailItem('Frecuencia:',
                                  _getFrequencyText(_reminder!.frequency)),
                              _buildDetailItem(
                                  'Notificación Activada:',
                                  _reminder!.isNotificationEnabled
                                      ? 'Sí'
                                      : 'No'),
                              if (_reminder!.createdAt != null)
                                _buildDetailItem(
                                    'Creado el:',
                                    DateFormat.yMMMd('es')
                                        .add_jm()
                                        .format(_reminder!.createdAt!)),
                              if (_reminder!.updatedAt != null)
                                _buildDetailItem(
                                    'Actualizado el:',
                                    DateFormat.yMMMd('es')
                                        .add_jm()
                                        .format(_reminder!.updatedAt!)),
                            ],
                          ),
                        ),
          // Overlay de carga cuando se elimina
          if (_isLoading &&
              _reminder !=
                  null) // Mostrar solo si no es la carga inicial y _reminder existe
            const Opacity(
              opacity: 0.8,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading && _reminder != null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Construye un ítem de detalle con etiqueta y valor.
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: AppTheme.textMedium)),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: AppTheme.textDark)),
          const Divider(color: AppTheme.inputFillColor),
        ],
      ),
    );
  }
}
