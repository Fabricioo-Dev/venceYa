// lib/ui/screens/add_edit_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';

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
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  ReminderCategory _selectedCategory = ReminderCategory.other;
  bool _isNotificationEnabled = false;

  bool _isLoading = false;
  String? _errorMessage;
  Reminder? _initialReminderData;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      _loadReminderData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadReminderData() async {
    setState(() => _isLoading = true);
    try {
      final reminder = await context
          .read<FirestoreService>()
          .getReminderById(widget.reminderId!);
      if (mounted && reminder != null) {
        setState(() {
          _initialReminderData = reminder;
          _titleController.text = reminder.title;
          _descriptionController.text = reminder.description ?? '';
          _selectedDate = reminder.dueDate;
          _selectedCategory = reminder.category;
          _isNotificationEnabled = reminder.isNotificationEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al cargar los datos.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 10)));
    if (pickedDate == null || !mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()));
    if (pickedTime == null) return;
    final selectedDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);
    if (selectedDateTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                const Text('No puedes seleccionar una fecha u hora pasada.'),
            backgroundColor: Theme.of(context).colorScheme.error));
      }
      return;
    }
    setState(() => _selectedDate = selectedDateTime);
  }

  Future<void> _saveReminder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDate == null) {
      setState(() => _errorMessage = "Por favor, selecciona una fecha.");
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firestoreService = context.read<FirestoreService>();
      final notificationService = context.read<LocalNotificationService>();
      final currentUser = context.read<AuthService>().currentUser!;

      final reminderToSave = Reminder(
        id: _initialReminderData?.id,
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDate!,
        category: _selectedCategory,
        isNotificationEnabled: _isNotificationEnabled,
        createdAt: _initialReminderData?.createdAt,
      );

      String reminderId;
      if (widget.isEditMode) {
        await firestoreService.updateReminder(reminderToSave);
        reminderId = reminderToSave.id!;
      } else {
        final docRef = await firestoreService.addReminder(reminderToSave);
        reminderId = docRef.id;
      }

      if (_isNotificationEnabled &&
          reminderToSave.dueDate.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(
          id: reminderId.hashCode,
          title: reminderToSave.title,
          body:
              'Vence: ${DateFormat.yMMMEd('es').add_jm().format(reminderToSave.dueDate)}',
          payload: reminderId,
          scheduledDate: reminderToSave.dueDate,
        );
      } else {
        await notificationService.cancelNotification(reminderId.hashCode);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.isEditMode
                ? 'Recordatorio actualizado'
                : 'Recordatorio añadido'),
            backgroundColor: AppTheme.categoryGreen));
        // Al terminar, navegamos explícitamente al Dashboard.
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al guardar. Inténtalo de nuevo.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isEditMode ? 'Editar Recordatorio' : 'Añadir Recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Se cambia `pop` por una navegación explícita a `/dashboard`.
          // Esto asegura que, sin importar de dónde vengas, la flecha
          // siempre te devolverá a la pantalla principal.
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) {
                    return 'Introduce un título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Descripción (Opcional)'),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildCategoryPicker(),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Activar Notificación'),
                value: _isNotificationEnabled,
                onChanged: (bool value) async {
                  if (value) {
                    final bool permissionsGranted = await context
                        .read<LocalNotificationService>()
                        .requestPermissions();
                    if (permissionsGranted && mounted) {
                      setState(() => _isNotificationEnabled = true);
                    }
                  } else {
                    setState(() => _isNotificationEnabled = false);
                  }
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.accentBlue,
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 16)),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                child: Text(widget.isEditMode ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Fecha y Hora'),
      subtitle: Text(
        _selectedDate == null
            ? 'Seleccionar...'
            : DateFormat.yMMMMEEEEd('es').add_jm().format(_selectedDate!),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _selectedDate == null
                  ? AppTheme.textMedium
                  : AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
      ),
      trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
      onTap: _pickDate,
    );
  }

  Widget _buildCategoryPicker() {
    return DropdownButtonFormField<ReminderCategory>(
      value: _selectedCategory,
      decoration: const InputDecoration(labelText: 'Categoría'),
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
