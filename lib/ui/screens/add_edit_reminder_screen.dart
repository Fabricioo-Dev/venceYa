// lib/ui/screens/add_edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importado para HapticFeedback
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/core/theme.dart';

// --- DEFINICIÓN DEL WIDGET ---
// AddEditReminderScreen es un "Widget Dinámico" (StatefulWidget) porque su contenido
// debe cambiar según la interacción del usuario y los datos cargados.
class AddEditReminderScreen extends StatefulWidget {
  // Recibe el ID del recordatorio. Si es nulo, estamos en modo "Añadir".
  final String? reminderId;

  const AddEditReminderScreen({super.key, this.reminderId});

  // Una propiedad computada para verificar fácilmente si estamos en modo edición.
  bool get isEditMode => reminderId != null;

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

// --- CLASE DE ESTADO DEL WIDGET ---
class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  // --- VARIABLES DE ESTADO ---
  final _formKey =
      GlobalKey<FormState>(); // Clave para controlar y validar el formulario.
  final _titleController =
      TextEditingController(); // Controlador para el campo de texto del título.
  // --- NUEVO CONTROLLER ---
  final _descriptionController =
      TextEditingController(); // Controlador para la descripción.

  // Variables para almacenar los datos del formulario.
  DateTime? _selectedDate;
  ReminderCategory _selectedCategory = ReminderCategory.other;
  bool _isNotificationEnabled = true;

  // Variables para controlar el estado de la UI.
  bool _isLoading = false;
  String? _errorMessage;
  Reminder?
      _initialReminderData; // Guarda los datos originales en modo edición.

  // --- CICLO DE VIDA ---
  @override
  void initState() {
    super.initState();
    // Si el widget está en modo edición, llamamos a la función para cargar los datos existentes.
    if (widget.isEditMode) {
      _loadReminderData();
    }
  }

  @override
  void dispose() {
    // Es CRUCIAL limpiar los controladores para liberar memoria.
    _titleController.dispose();
    _descriptionController.dispose(); // Limpiamos el nuevo controller.
    super.dispose();
  }

  // --- LÓGICA DE DATOS ---

  /// Carga los datos de un recordatorio existente desde Firestore.
  Future<void> _loadReminderData() async {
    setState(() => _isLoading = true);
    try {
      final reminder = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId!);

      if (mounted) {
        setState(() {
          if (reminder != null) {
            _initialReminderData = reminder;
            _titleController.text = reminder.title;
            _descriptionController.text =
                reminder.description ?? ''; // Cargamos la descripción.
            _selectedDate = reminder.dueDate;
            _selectedCategory = reminder.category;
            _isNotificationEnabled = reminder.isNotificationEnabled;
          } else {
            _errorMessage = "Recordatorio no encontrado.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al cargar: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Guarda un nuevo recordatorio o actualiza uno existente.
  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      setState(() => _errorMessage = "Por favor, seleccione una fecha.");
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final localNotificationService = context.read<LocalNotificationService>();
      final currentUser = authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception("Usuario no autenticado.");
      }

      // Crea el objeto Reminder con los datos del formulario.
      final reminder = Reminder(
        id: widget.isEditMode ? _initialReminderData!.id : null,
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim(), // Guardamos la descripción.
        dueDate: _selectedDate!,
        category: _selectedCategory,
        isNotificationEnabled: _isNotificationEnabled,
        createdAt: widget.isEditMode
            ? _initialReminderData!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final String reminderId;
      if (widget.isEditMode) {
        await firestoreService.updateReminder(reminder);
        reminderId = reminder.id!;
      } else {
        final docRef = await firestoreService.addReminder(reminder);
        reminderId = docRef.id;
      }

      final notificationId = reminderId.hashCode & 0x7FFFFFFF;
      if (reminder.isNotificationEnabled &&
          reminder.dueDate.isAfter(DateTime.now())) {
        await localNotificationService.scheduleNotification(
          id: notificationId,
          title: reminder.title,
          body:
              'Vence hoy: ${DateFormat.yMMMd('es').add_jm().format(reminder.dueDate)}',
          scheduledDate: reminder.dueDate,
          payload: reminderId,
        );
      } else {
        await localNotificationService.cancelNotification(notificationId);
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(widget.isEditMode
              ? 'Recordatorio actualizado con éxito!'
              : 'Recordatorio añadido con éxito!'),
          backgroundColor: AppTheme.categoryGreen,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      navigator.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al guardar: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MÉTODOS AYUDANTES PARA LA UI ---

  /// Muestra el selector de fecha y hora, y valida que no sea una hora pasada.
  Future<void> _pickDate() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  onSurface: AppTheme.textMedium,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _selectedDate ?? DateTime.now().add(const Duration(hours: 1))),
    );
    if (pickedTime == null) return;

    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selectedDateTime.isBefore(DateTime.now())) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('No puedes seleccionar una fecha u hora pasada.'),
          backgroundColor: AppTheme.categoryRed,
        ),
      );
      return;
    }

    setState(() {
      HapticFeedback.lightImpact(); // Añade una vibración sutil.
      _selectedDate = selectedDateTime;
    });
  }

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

  // --- CONSTRUCCIÓN DE LA UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditMode ? 'Editar Recordatorio' : 'Añadir Recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: _isLoading && _initialReminderData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del Recordatorio',
                            hintText: 'Ej. Pagar alquiler',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor, introduce un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // --- CAMPO DE DESCRIPCIÓN AÑADIDO ---
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción (Opcional)',
                            hintText: 'Añade detalles adicionales aquí...',
                          ),
                          maxLines: 3, // Permite que el campo sea multilínea.
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Fecha y Hora de Vencimiento',
                              style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(
                            _selectedDate == null
                                ? 'Seleccionar...'
                                : DateFormat.yMMMd('es')
                                    .add_jm()
                                    .format(_selectedDate!),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: _selectedDate == null
                                        ? AppTheme.textMedium
                                        : AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.calendar_today,
                              color: AppTheme.primaryBlue),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<ReminderCategory>(
                          value: _selectedCategory,
                          decoration:
                              const InputDecoration(labelText: 'Categoría'),
                          items: ReminderCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(_getCategoryText(category)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _selectedCategory = newValue);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: Text('Activar Notificación',
                              style: Theme.of(context).textTheme.titleMedium),
                          value: _isNotificationEnabled,
                          onChanged: (value) {
                            setState(() => _isNotificationEnabled = value);
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveReminder,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50)),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  widget.isEditMode ? 'Actualizar' : 'Guardar'),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.categoryRed, fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading) ...[
                  const ModalBarrier(dismissible: false, color: Colors.black54),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
    );
  }
}
