import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> createUserIfNotExists(String userId) async {
    final userRef = _db.collection('usuarios').doc(userId);

    if (!(await userRef.get()).exists) {
      await userRef.set({
        'saldoSimulado': 10000.0, // Balance inicial ficticio
        'saldoReal': 0.0, // Balance inicial real
      });
    }
  }

  /// Crear o actualizar un usuario
  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('usuarios').doc(uid).set(userData, SetOptions(merge: true));
  }

  /// Obtener datos de un usuario
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('usuarios').doc(uid).get();
  }

  /// Actualizar saldos de un usuario (para billetera)
  Future<void> updateUserBalance(String userId, double saldoSimulado, double saldoReal) async {
    await _db.collection('usuarios').doc(userId).update({
      'saldoSimulado': saldoSimulado,
      'saldoReal': saldoReal,
    });
  }

  /// Registrar una transacción (Compra/Venta)
  Future<void> saveTransaction(Map<String, dynamic> transactionData) async {
    await _db.collection('transacciones').add(transactionData);
  }

  /// Obtener todas las transacciones de un usuario
  Future<QuerySnapshot> getUserTransactions(String userId) async {
    return await _db.collection('transacciones').where('userId', isEqualTo: userId).get();
  }

  /// Obtener un activo por su ID
  Future<DocumentSnapshot> getActivo(String activoId) async {
    return await _db.collection('activos').doc(activoId).get();
  }

  /// Obtener todos los activos disponibles
  Future<QuerySnapshot> getActivos() async {
    return await _db.collection('activos').get();
  }

  /// Guardar o actualizar suscripción
  Future<void> saveSubscription(String userId, Map<String, dynamic> subscriptionData) async {
    await _db.collection('suscripciones').doc(userId).set(subscriptionData, SetOptions(merge: true));
  }

  /// Obtener suscripción de un usuario
  Future<DocumentSnapshot> getSubscription(String userId) async {
    return await _db.collection('suscripciones').doc(userId).get();
  }

  /// Obtener noticias financieras
  Future<QuerySnapshot> getNoticias() async {
    return await _db.collection('noticias').orderBy('fecha', descending: true).get();
  }

  /// Registrar simulaciones realizadas por el usuario
  Future<void> saveSimulation(String userId, Map<String, dynamic> simulationData) async {
    await _db.collection('simulaciones').doc(userId).set({
      'historial': FieldValue.arrayUnion([simulationData])
    }, SetOptions(merge: true));
  }

  /// Obtener historial de simulaciones de un usuario
  Future<DocumentSnapshot> getSimulations(String userId) async {
    return await _db.collection('simulaciones').doc(userId).get();
  }

  /// Registrar análisis realizado por el usuario
  Future<void> saveAnalysis(String userId, Map<String, dynamic> analysisData) async {
    await _db.collection('analisis').doc(userId).set({
      'historial': FieldValue.arrayUnion([analysisData])
    }, SetOptions(merge: true));
  }

  /// Obtener historial de análisis de un usuario
  Future<DocumentSnapshot> getAnalyses(String userId) async {
    return await _db.collection('analisis').doc(userId).get();
  }
}
