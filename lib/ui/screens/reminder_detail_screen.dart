// lib/ui/screens/reminder_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/core/theme.dart';

// --- DEFINICIÓN DEL WIDGET ---
// ReminderDetailScreen es un "Widget Dinámico" (StatefulWidget).
// ¿Por qué? Porque su contenido principal (los detalles del recordatorio) no está disponible
// de inmediato. Necesita:
// 1. Iniciar un estado de "cargando" (`_isLoading`).
// 2. Pedir los datos a Firestore de forma asíncrona.
// 3. "Recordar" los datos del recordatorio (`_reminder`) una vez que llegan.
// 4. Reconstruir su UI para mostrar los datos o un mensaje de error.
class ReminderDetailScreen extends StatefulWidget {
  // Recibe el ID del recordatorio desde la ruta de GoRouter. Es 'required'
  // porque esta pantalla no tiene sentido sin un ID para buscar.
  final String reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

// --- CLASE DE ESTADO DEL WIDGET ---
class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  // --- VARIABLES DE ESTADO ---
  Reminder?
      _reminder; // Almacenará los datos del recordatorio una vez cargados.
  bool _isLoading = true; // Controla si se muestra un indicador de carga.
  String? _errorMessage; // Almacena un mensaje de error si la carga falla.

  // --- CICLO DE VIDA DEL WIDGET ---
  @override
  void initState() {
    super.initState();
    // En cuanto el widget se inicializa, lanzamos la carga de los datos.
    _loadReminder();
  }

  // --- LÓGICA DE DATOS ---

  /// Carga los detalles del recordatorio desde Firestore usando el ID del widget.
  Future<void> _loadReminder() async {
    // Activamos el estado de carga y limpiamos errores previos.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Usamos Provider para acceder a nuestro servicio y pedir los datos.
      final reminder = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId);

      // Comprobamos si el widget sigue "montado" (en pantalla) antes de actualizar el estado.
      // Es una buena práctica para evitar errores si el usuario navega fuera de la pantalla
      // justo cuando los datos están llegando.
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
      // El bloque `finally` se ejecuta siempre, haya éxito o error.
      // Es el lugar perfecto para asegurarnos de desactivar el estado de carga.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Muestra un diálogo de confirmación y, si se confirma, elimina el recordatorio.
  Future<void> _deleteReminder() async {
    if (_reminder == null) return;

    // `showDialog` es asíncrono. Pausa la ejecución hasta que el usuario cierra el diálogo.
    // El valor que devuelve (`true` o `false`) depende del botón que el usuario presione.
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este recordatorio? Esta acción no se puede deshacer.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Devuelve false
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Devuelve true
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.categoryRed,
                foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // Si el usuario no confirmó (presionó "Cancelar" o fuera del diálogo), no hacemos nada.
    if (confirmDelete != true) return;

    setState(() => _isLoading = true);

    try {
      // 1. Elimina el documento de Firestore.
      await context.read<FirestoreService>().deleteReminder(_reminder!.id!);

      // 2. Cancela la notificación local asociada a este recordatorio.
      // Usamos el mismo método para generar el ID que al crearla.
      final notificationId = _reminder!.id!.hashCode & 0x7FFFFFFF;
      await context
          .read<LocalNotificationService>()
          .cancelNotification(notificationId);

      if (mounted) {
        // Mostramos una barra de feedback al usuario.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recordatorio eliminado con éxito.'),
            backgroundColor: AppTheme.categoryGreen,
          ),
        );
        // Regresamos al dashboard después de eliminar.
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al eliminar: ${e.toString()}";
          _isLoading = false; // Aseguramos que el loading pare si hay error.
        });
      }
    }
  }

  // --- MÉTODOS AYUDANTES PARA LA UI ---

  /// Convierte el enum de Categoría a texto legible en español.
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

  /// Convierte el enum de Frecuencia a texto legible en español.
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
    }
  }

  /// Construye un widget reutilizable para mostrar un par de Label/Value.
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

  /// Construye el cuerpo del Scaffold basado en el estado actual (carga, error, éxito).
  /// Separar esta lógica del `build` principal hace el código mucho más limpio y legible.
  Widget _buildBody() {
    // 1. Si está cargando y aún no tenemos datos, muestra un cargador.
    if (_isLoading && _reminder == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // 2. Si hubo un error, muestra el mensaje de error.
    if (_errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.categoryRed, fontSize: 16)),
      ));
    }
    // 3. Si terminó de cargar pero no se encontró el recordatorio, muestra un mensaje.
    if (_reminder == null) {
      return const Center(child: Text('Recordatorio no disponible.'));
    }

    // 4. Si todo está bien, muestra los detalles del recordatorio.
    return RefreshIndicator(
      onRefresh:
          _loadReminder, // Permite refrescar los datos deslizando hacia abajo.
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildDetailItem('Título:', _reminder!.title),
          _buildDetailItem(
              'Vence el:',
              // Usamos un formato de fecha más completo para el detalle.
              DateFormat.yMMMMEEEEd('es').add_jm().format(_reminder!.dueDate)),
          _buildDetailItem('Categoría:', _getCategoryText(_reminder!.category)),
          _buildDetailItem(
              'Frecuencia:', _getFrequencyText(_reminder!.frequency)),
          _buildDetailItem('Notificación Habilitada:',
              _reminder!.isNotificationEnabled ? 'Sí' : 'No'),

          // Solo construimos los siguientes widgets si el valor de la fecha no es nulo.
          if (_reminder!.createdAt != null)
            _buildDetailItem(
                'Creado el:',
                // Ahora es seguro usar '!' porque el if ya comprobó que no es nulo.
                DateFormat.yMMMd('es').add_jm().format(_reminder!.createdAt!)),

          if (_reminder!.updatedAt != null)
            _buildDetailItem('Última Actualización:',
                DateFormat.yMMMd('es').add_jm().format(_reminder!.updatedAt!)),
        ],
      ),
    );
  }

  // --- MÉTODO PRINCIPAL DE CONSTRUCCIÓN ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Añadimos la flecha para volver atrás.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        // El título del AppBar se actualiza dinámicamente con el título del recordatorio.
        title: Text(_reminder?.title ?? 'Detalle'),
        // Las acciones (botones de editar/eliminar) solo aparecen si los datos
        // del recordatorio ya se cargaron y no estamos en medio de otra operación.
        actions: _reminder == null || _isLoading
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Recordatorio',
                  onPressed: () => context.goNamed('editReminder',
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
      // El cuerpo del Scaffold es un Stack para poder mostrar una capa de carga
      // por encima del contenido cuando se está eliminando.
      body: Stack(
        children: [
          // El cuerpo principal que se decide en el método _buildBody().
          _buildBody(),

          // Si estamos cargando (ej. durante la eliminación), mostramos un overlay.
          // La condición `_reminder != null` asegura que este overlay solo aparezca
          // durante la eliminación y no durante la carga inicial.
          if (_isLoading && _reminder != null) ...[
            const ModalBarrier(dismissible: false, color: Colors.black54),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
