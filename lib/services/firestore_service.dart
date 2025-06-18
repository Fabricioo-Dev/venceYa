// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';
import '../models/user_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Operaciones para Reminders ---

  /// Agrega un nuevo recordatorio a Firestore.
  /// El ID del recordatorio se generará automáticamente por Firestore.
  Future<DocumentReference> addReminder(Reminder reminder) async {
    try {
      // Asegurarse de que createdAt se establece si es nulo
      final reminderData = reminder.copyWith(
        createdAt: reminder.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _firestore
          .collection('reminders')
          .add(reminderData.toJson());
    } catch (e) {
      print('Error al agregar recordatorio: $e');
      throw Exception('No se pudo agregar el recordatorio.');
    }
  }

  /// Actualiza un recordatorio existente en Firestore.
  Future<void> updateReminder(Reminder reminder) async {
    if (reminder.id == null) {
      throw Exception(
          'El ID del recordatorio no puede ser nulo para actualizar.');
    }
    try {
      final reminderData = reminder.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('reminders')
          .doc(reminder.id)
          .update(reminderData.toJson());
    } catch (e) {
      print('Error al actualizar recordatorio: $e');
      throw Exception('No se pudo actualizar el recordatorio.');
    }
  }

  /// Elimina un recordatorio de Firestore.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      print('Error al eliminar recordatorio: $e');
      throw Exception('No se pudo eliminar el recordatorio.');
    }
  }

  /// Obtiene un stream de la lista de recordatorios para un usuario específico.
  /// Ordenados por fecha de vencimiento.
  Stream<List<Reminder>> getRemindersStream(String userId) {
    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reminder.fromJson(doc.data())
            .copyWith(id: doc.id);
      }).toList();
    });
  }

  /// Obtiene un recordatorio específico por su ID.
  Future<Reminder?> getReminderById(String reminderId) async {
    try {
      final docSnapshot =
          await _firestore.collection('reminders').doc(reminderId).get();
      if (docSnapshot.exists) {
        return Reminder.fromJson(docSnapshot.data() as Map<String, dynamic>)
            .copyWith(id: docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener recordatorio por ID: $e');
      throw Exception('No se pudo obtener el recordatorio.');
    }
  }

  // --- Operaciones para UserData ---

  /// Crea o actualiza el registro de un usuario en Firestore.
  /// Se usa doc(userData.uid).set() para crear si no existe o sobrescribir si existe.
  Future<void> setUserData(UserData userData) async {
    try {
      // Asegurarse de que createdAt se establece si es nulo (para nuevos usuarios)
      final dataToSet = userData.createdAt == null
          ? userData.copyWith(createdAt: DateTime.now())
          : userData;
      await _firestore.collection('users').doc(userData.uid).set(
          dataToSet.toJson(),
          SetOptions(
              merge:
                  true)); // merge:true para no sobrescribir campos no enviados
    } catch (e) {
      print('Error al crear/actualizar registro de usuario: $e');
      throw Exception('No se pudo guardar la información del usuario.');
    }
  }

  /// Obtiene el registro de UserData para un usuario específico.
  Future<UserData?> getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserData.fromJson(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error al obtener registro de usuario: $e');
      return null; // No lanzar excepción aquí necesariamente, podría ser que el usuario no tenga registro aún.
    }
  }

  /// Actualiza campos específicos del registro de un usuario.
  /// Utiliza update() para modificar solo los campos provistos.
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error al actualizar datos del usuario: $e');
      throw Exception('No se pudo actualizar la información del usuario.');
    }
  }
}
