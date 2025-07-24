// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:venceya/models/reminder.dart';
import 'package:venceya/models/user_data.dart';

/// Servicio que encapsula toda la comunicación con la base de datos Firestore.
///
/// Esta clase es la única que debe interactuar con Firestore, creando una
/// "capa de acceso a datos" que mantiene el resto de la app desacoplada.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Getter para la referencia a la colección de usuarios.
  /// Usar un getter evita repetir el string 'users' y previene errores de tipeo.
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Getter para la referencia a la colección de recordatorios.
  CollectionReference<Map<String, dynamic>> get _remindersRef =>
      _firestore.collection('reminders');

  // --- Operaciones para Recordatorios (Reminders) ---

  /// Agrega un nuevo recordatorio a Firestore.
  Future<DocumentReference> addReminder(Reminder reminder) {
    try {
      final now = DateTime.now();
      // Asegura que las fechas de creación y actualización se estampen al crear.
      final reminderWithTimestamps = reminder.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      // No se necesita `await` al retornar un Future.
      return _remindersRef.add(reminderWithTimestamps.toJson());
    } catch (e) {
      // En un entorno real, aquí se usaría un servicio de logging.
      print('Error en addReminder: $e');
      // `rethrow` relanza la excepción original, conservando el tipo y
      // el `stacktrace`, lo que permite un manejo de errores más específico en la UI.
      rethrow;
    }
  }

  /// Actualiza un recordatorio existente en Firestore.
  Future<void> updateReminder(Reminder reminder) async {
    // Cláusula de guarda: es imposible actualizar sin un ID.
    if (reminder.id == null) {
      throw ArgumentError(
          'El ID del recordatorio no puede ser nulo para actualizar.');
    }
    try {
      final reminderWithTimestamp =
          reminder.copyWith(updatedAt: DateTime.now());
      await _remindersRef
          .doc(reminder.id)
          .update(reminderWithTimestamp.toJson());
    } catch (e) {
      print('Error en updateReminder: $e');
      rethrow;
    }
  }

  /// Elimina un recordatorio de Firestore por su ID.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _remindersRef.doc(reminderId).delete();
    } catch (e) {
      print('Error en deleteReminder: $e');
      rethrow;
    }
  }

  /// Obtiene un stream con la lista de recordatorios de un usuario.
  Stream<List<Reminder>> getRemindersStream(String userId) {
    return _remindersRef
        .where('userId', isEqualTo: userId)
        .orderBy('dueDate', descending: false)
        .snapshots() // Emite nuevos valores en tiempo real cuando los datos cambian.
        .map((snapshot) => snapshot.docs.map((doc) {
              // Combina el ID del documento con sus datos en un objeto Reminder.
              return Reminder.fromJson(doc.data()).copyWith(id: doc.id);
            }).toList());
  }

  /// Obtiene un único recordatorio por su ID (lectura de una sola vez).
  Future<Reminder?> getReminderById(String reminderId) async {
    try {
      final docSnapshot = await _remindersRef.doc(reminderId).get();
      if (docSnapshot.exists) {
        return Reminder.fromJson(docSnapshot.data()!)
            .copyWith(id: docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error en getReminderById: $e');
      rethrow;
    }
  }

  // --- Operaciones para Usuarios (Users) ---

  /// Crea o actualiza los datos de un usuario.
  Future<void> setUserData(UserData userData) async {
    try {
      // `set` con `merge: true` crea o actualiza datos sin sobreescribir
      // campos que no se envíen. Crucial para no perder información.
      await _usersRef
          .doc(userData.uid)
          .set(userData.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error en setUserData: $e');
      rethrow;
    }
  }

  /// Obtiene los datos de un usuario por su ID.
  Future<UserData?> getUserData(String userId) async {
    try {
      final docSnapshot = await _usersRef.doc(userId).get();
      return docSnapshot.exists ? UserData.fromJson(docSnapshot.data()!) : null;
    } catch (e) {
      print('Error en getUserData: $e');
      // En este caso, no relanzamos la excepción. Es un caso de uso común
      // que un usuario nuevo no tenga datos, y no es un error crítico.
      // Devolver `null` es una respuesta válida que la UI puede manejar.
      return null;
    }
  }

  /// Actualiza campos específicos de un usuario (ej: solo `lastLogin`).
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(userId).update(data);
    } catch (e) {
      print('Error en updateUserData: $e');
      rethrow;
    }
  }
}
