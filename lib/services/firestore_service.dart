// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reminder.dart';
import '../models/user_data.dart';

/// Clase de servicio que encapsula TODA la comunicación con la base de datos Firestore.
/// Esta es tu "Capa de Acceso a Datos". Ninguna otra parte de la app (especialmente la UI)
/// debería hablar directamente con Firestore. Esto mantiene el código organizado y fácil de mantener.
class FirestoreService {
  // La instancia principal de FirebaseFirestore. Es nuestra puerta de entrada a la base de datos.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Operaciones para la colección 'reminders' ---

  /// Agrega un nuevo recordatorio a Firestore.
  /// Firestore generará automáticamente un ID único para el documento.
  Future<DocumentReference> addReminder(Reminder reminder) async {
    try {
      // Usamos .copyWith() para asegurar que la fecha de actualización siempre esté presente.
      final reminderData = reminder.copyWith(updatedAt: DateTime.now());

      // .collection('reminders') -> Accede a la colección de recordatorios.
      // .add() -> Añade un nuevo documento con los datos provistos y un ID automático.
      return await _firestore
          .collection('reminders')
          .add(reminderData.toJson());
    } catch (e) {
      // Si algo sale mal (ej. problemas de red, permisos), se captura el error.
      print('Error al agregar recordatorio: $e');
      // Lanzamos una nueva excepción para que la capa superior (la UI) pueda manejarla.
      throw Exception('No se pudo agregar el recordatorio.');
    }
  }

  /// Actualiza un recordatorio existente en Firestore usando su ID.
  Future<void> updateReminder(Reminder reminder) async {
    // Es crucial tener un ID para saber qué documento actualizar.
    if (reminder.id == null) {
      throw Exception(
          'El ID del recordatorio no puede ser nulo para actualizar.');
    }
    try {
      final reminderData = reminder.copyWith(updatedAt: DateTime.now());
      // .doc(reminder.id) -> Apunta a un documento específico dentro de la colección.
      // .update() -> Modifica los campos del documento con los nuevos datos.
      await _firestore
          .collection('reminders')
          .doc(reminder.id)
          .update(reminderData.toJson());
    } catch (e) {
      print('Error al actualizar recordatorio: $e');
      throw Exception('No se pudo actualizar el recordatorio.');
    }
  }

  /// Elimina un recordatorio de Firestore por su ID.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      print('Error al eliminar recordatorio: $e');
      throw Exception('No se pudo eliminar el recordatorio.');
    }
  }

  /// Obtiene un stream (flujo de datos en tiempo real) de los recordatorios de un usuario.
  Stream<List<Reminder>> getRemindersStream(String userId) {
    
    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      // El .map transforma los datos crudos de Firestore en lo que necesitamos.
      return snapshot.docs.map((doc) {
        // Para cada documento...
        // 1. Lo convertimos de un mapa (JSON) a nuestro objeto Dart `Reminder`.
        // 2. El ID del documento vive fuera de sus datos, así que lo inyectamos usando .copyWith().
        return Reminder.fromJson(doc.data()).copyWith(id: doc.id);
      }).toList(); // Convertimos el resultado en una lista.
    });
  }

  /// Obtiene un único recordatorio por su ID (lectura de una sola vez).
  Future<Reminder?> getReminderById(String reminderId) async {
    try {
      // .get() -> Realiza una lectura única del documento. No escucha cambios.
      final docSnapshot =
          await _firestore.collection('reminders').doc(reminderId).get();
      if (docSnapshot.exists) {
        // Si el documento existe, lo procesamos y lo devolvemos.
        return Reminder.fromJson(docSnapshot.data()!)
            .copyWith(id: docSnapshot.id);
      }
      // Si no existe, devolvemos nulo.
      return null;
    } catch (e) {
      print('Error al obtener recordatorio por ID: $e');
      throw Exception('No se pudo obtener el recordatorio.');
    }
  }

  // --- Operaciones para la colección 'users' ---

  /// Crea o actualiza completamente el documento de un usuario.
  Future<void> setUserData(UserData userData) async {
    try {
      // .doc(userData.uid) -> Usamos el UID de Firebase Auth como ID del documento.
      // .set() -> Crea el documento si no existe, o lo REEMPLAZA por completo si ya existe.
      await _firestore.collection('users').doc(userData.uid).set(
            userData.toJson(),
            // SetOptions(merge: true) es MUY IMPORTANTE. Le dice a Firestore que si
            // el documento ya existe, en lugar de borrarlo y crearlo de nuevo,
            // solo actualice o añada los campos que vienen en `userData.toJson()`.
            // Esto previene la pérdida de datos si no enviamos el objeto completo.
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error al crear/actualizar registro de usuario: $e');
      throw Exception('No se pudo guardar la información del usuario.');
    }
  }

  /// Obtiene los datos de un usuario por su ID.
  Future<UserData?> getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserData.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error al obtener registro de usuario: $e');
      // Aquí devolvemos null en lugar de lanzar una excepción, porque es un caso
      // esperado que un usuario nuevo (ej. login con Google) aún no tenga registro.
      return null;
    }
  }

  /// Actualiza campos específicos de un usuario (ej. solo `lastLogin`).
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      // .update() es perfecto para modificar solo uno o más campos sin afectar el resto del documento.
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error al actualizar datos del usuario: $e');
      throw Exception('No se pudo actualizar la información del usuario.');
    }
  }
}
