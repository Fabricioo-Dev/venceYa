// lib/ui/screens/add_edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/core/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditReminderScreen extends StatefulWidget {
  final String? reminderId;

  const AddEditReminderScreen({super.key, this.reminderId});

  bool get isEditMode => reminderId != null;

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  ReminderCategory _selectedCategory = ReminderCategory.other;
  ReminderFrequency _selectedFrequency = ReminderFrequency.none;
  bool _isNotificationEnabled = true;

  bool _isLoading =
      false; // Indica si hay una operación de guardado/carga en curso
  String? _errorMessage;
  Reminder? _initialReminderData;

  /// Inicializa el estado del widget. Si es modo edición, carga los datos del recordatorio.
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadReminderData();
    }
  }

  /// Carga los datos de un recordatorio existente para precargar el formulario en modo edición.
  Future<void> _loadReminderData() async {
    setState(() => _isLoading = true);
    try {
      final reminder = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId!);
      if (reminder != null) {
        _initialReminderData = reminder;
        _titleController.text = _initialReminderData!.title;
        _selectedDate = _initialReminderData!.dueDate;
        _selectedCategory = _initialReminderData!.category;
        _selectedFrequency = _initialReminderData!.frequency;
        _isNotificationEnabled = _initialReminderData!.isNotificationEnabled;
      } else {
        _errorMessage = "Recordatorio no encontrado.";
      }
    } catch (e) {
      _errorMessage = "Error al cargar el recordatorio: $e";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Muestra un selector de fecha y hora para la fecha de vencimiento, sin fechas pasadas.
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDate != null
            ? TimeOfDay.fromDateTime(_selectedDate!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Guarda un nuevo recordatorio o actualiza uno existente en Firestore y programa notificaciones locales.
  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        if (mounted)
          setState(() => _errorMessage =
              "Por favor, seleccione una fecha de vencimiento.");
        return;
      }
      // Mostrar el indicador de carga y deshabilitar el botón inmediatamente.
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final localNotificationService = context.read<LocalNotificationService>();
      final currentUser = authService.getCurrentUser();

      if (currentUser == null) {
        if (mounted)
          setState(() {
            _errorMessage = "Usuario no autenticado.";
            _isLoading = false; // Ocultar carga si no hay usuario
          });
        return;
      }

      final reminder = Reminder(
        id: widget.isEditMode ? _initialReminderData!.id : null,
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        dueDate: _selectedDate!,
        category: _selectedCategory,
        frequency: _selectedFrequency,
        isNotificationEnabled: _isNotificationEnabled,
        createdAt: widget.isEditMode
            ? _initialReminderData!.createdAt
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        String? reminderIdForNotification;
        if (widget.isEditMode) {
          await firestoreService.updateReminder(reminder);
          reminderIdForNotification = reminder.id;
          // Mensaje de éxito antes de navegar para mejor UX
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Recordatorio actualizado con éxito!')),
          );
        } else {
          final docRef = await firestoreService.addReminder(reminder);
          reminderIdForNotification = docRef.id;
          // Mensaje de éxito antes de navegar para mejor UX
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recordatorio añadido con éxito!')),
          );
        }

        if (reminderIdForNotification != null) {
          final notificationId =
              reminderIdForNotification.hashCode & 0x7FFFFFFF;
          if (reminder.isNotificationEnabled &&
              reminder.dueDate.isAfter(DateTime.now())) {
            await localNotificationService.scheduleNotification(
              id: notificationId,
              title: reminder.title,
              body:
                  'Vence hoy: ${DateFormat.yMMMd('es').add_jm().format(reminder.dueDate)}',
              scheduledDate: reminder.dueDate,
              payload: reminderIdForNotification,
            );
          } else {
            await localNotificationService.cancelNotification(notificationId);
          }
        }

        // ¡Navegar al Dashboard SÓLO después de la operación exitosa y feedback!
        if (mounted) context.go('/dashboard');
      } on Exception catch (e) {
        if (mounted) {
          setState(() => _errorMessage = "Error al guardar: ${e.toString()}");
        }
      } finally {
        // Aseguramos que el indicador de carga se oculte SIEMPRE al final
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  /// Libera los controladores de texto cuando el widget se destruye.
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditMode ? 'Editar Recordatorio' : 'Añadir Recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'), // Volver al Dashboard
        ),
      ),
      body: _isLoading &&
              widget.isEditMode &&
              _initialReminderData == null // Para carga inicial en modo edición
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              // Usamos Stack para el overlay de carga al guardar
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título del Recordatorio',
                            hintText: 'Ej. Pagar alquiler, Renovación seguro',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce un título';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Fecha y Hora de Vencimiento:',
                            style: Theme.of(context).textTheme.titleMedium),
                        ListTile(
                          title: Text(
                            _selectedDate == null
                                ? 'Seleccionar Fecha y Hora'
                                : DateFormat.yMMMd('es')
                                    .add_jm()
                                    .format(_selectedDate!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: AppTheme.textDark),
                          ),
                          trailing: const Icon(Icons.calendar_today,
                              color: AppTheme.primaryBlue),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 20),
                        Text('Categoría:',
                            style: Theme.of(context).textTheme.titleMedium),
                        DropdownButtonFormField<ReminderCategory>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: AppTheme.inputFillColor,
                          ),
                          items: ReminderCategory.values
                              .map((ReminderCategory category) {
                            return DropdownMenuItem<ReminderCategory>(
                              value: category,
                              child: Text(_getCategoryText(category)),
                            );
                          }).toList(),
                          onChanged: (ReminderCategory? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedCategory = newValue);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Frecuencia:',
                            style: Theme.of(context).textTheme.titleMedium),
                        DropdownButtonFormField<ReminderFrequency>(
                          value: _selectedFrequency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: AppTheme.inputFillColor,
                          ),
                          items: ReminderFrequency.values
                              .map((ReminderFrequency freq) {
                            return DropdownMenuItem<ReminderFrequency>(
                              value: freq,
                              child: Text(_getFrequencyText(freq)),
                            );
                          }).toList(),
                          onChanged: (ReminderFrequency? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedFrequency = newValue);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: Text('Activar Notificación',
                              style: Theme.of(context).textTheme.titleMedium),
                          value: _isNotificationEnabled,
                          onChanged: (bool value) {
                            setState(() => _isNotificationEnabled = value);
                          },
                          activeColor: AppTheme.accentBlue,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _saveReminder, // <<-- DESHABILITADO DURANTE CARGA
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50)),
                          child: Text(
                              widget.isEditMode ? 'Actualizar' : 'Guardar'),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    color: AppTheme.categoryRed, fontSize: 16)),
                          ),
                      ],
                    ),
                  ),
                ),
                // Overlay de carga cuando se guarda/actualiza
                if (_isLoading &&
                    !(widget.isEditMode && _initialReminderData == null))
                  const Opacity(
                    opacity: 0.8,
                    child:
                        ModalBarrier(dismissible: false, color: Colors.black),
                  ),
                if (_isLoading &&
                    !(widget.isEditMode && _initialReminderData == null))
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
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
}
