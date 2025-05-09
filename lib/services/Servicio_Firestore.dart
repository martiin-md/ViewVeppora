import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crear usuario con saldo inicial si no existe o si no tiene los campos de saldo
  Future<void> createUserIfNotExists(String userId) async {
    final userRef = _db.collection('usuarios').doc(userId);
    final doc = await userRef.get();

    if (!doc.exists || !(doc.data()?.containsKey('saldoSimulado') ?? false)) {
      await userRef.set({
        'saldoSimulado': 200.0, // Saldo ficticio inicial
        'saldoReal': 0.0,
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('usuarios').doc(uid).set(userData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('usuarios').doc(uid).get();
  }

  Future<void> updateUserBalance(String userId, double saldoSimulado, double saldoReal) async {
    await _db.collection('usuarios').doc(userId).update({
      'saldoSimulado': saldoSimulado,
      'saldoReal': saldoReal,
    });
  }

  Future<void> saveTransaction({
    required String userId,
    required String tipo,
    required String activo,
    required int cantidad,
    required double precio,
  }) async {
    await _db.collection('transacciones').add({
      'userId': userId,
      'tipo': tipo,
      'activo': activo,
      'cantidad': cantidad,
      'precio': precio,
      'fecha': Timestamp.now(),
    });
  }

  Future<QuerySnapshot> getUserTransactions(String userId) async {
    return await _db.collection('transacciones')
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .get();
  }

  Future<DocumentSnapshot> getActivo(String activoId) async {
    return await _db.collection('activos').doc(activoId).get();
  }

  Future<QuerySnapshot> getActivos() async {
    return await _db.collection('activos').get();
  }

  Future<void> saveSubscription(String userId, Map<String, dynamic> subscriptionData) async {
    await _db.collection('suscripciones').doc(userId).set(subscriptionData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getSubscription(String userId) async {
    return await _db.collection('suscripciones').doc(userId).get();
  }

  Future<QuerySnapshot> getNoticias() async {
    return await _db.collection('noticias').get();
  }

  Future<void> saveSimulation(String userId, Map<String, dynamic> simulationData) async {
    await _db.collection('simulaciones').doc(userId).set({
      'historial': FieldValue.arrayUnion([simulationData])
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getSimulations(String userId) async {
    return await _db.collection('simulaciones').doc(userId).get();
  }

  Future<void> saveAnalysis(String userId, Map<String, dynamic> analysisData) async {
    await _db.collection('analisis').doc(userId).set({
      'historial': FieldValue.arrayUnion([analysisData])
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getAnalyses(String userId) async {
    return await _db.collection('analisis').doc(userId).get();
  }

  /// Actualiza solo el saldo simulado (compra o venta)
  Future<void> updateSimulatedBalance(String userId, double cantidad, {bool sumar = true}) async {
    final userRef = _db.collection('usuarios').doc(userId);
    final doc = await userRef.get();
    final actual = doc['saldoSimulado'] ?? 0.0;
    final nuevo = sumar ? actual + cantidad : actual - cantidad;

    await userRef.update({'saldoSimulado': nuevo});
  }

  /// Guarda el portafolio de criptomonedas del usuario
  Future<void> saveUserCriptoPortfolio(String userId, Map<String, int> portfolio) async {
    await _db.collection('usuarios').doc(userId).update({
      'portafolioCriptos': portfolio,
    });
  }

  /// Obtiene el portafolio de criptomonedas del usuario
  Future<Map<String, int>> getUserCriptoPortfolio(String userId) async {
    final doc = await _db.collection('usuarios').doc(userId).get();
    if (doc.exists && doc.data()!.containsKey('portafolioCriptos')) {
      final data = doc.data()!;
      final Map<String, dynamic> raw = data['portafolioCriptos'];
      return raw.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }

  Future<String> comprarSuscripcionPremium(String userId, FirestoreService firestore) async {
    try {
      final userDoc = await firestore.getUser(userId);
      final saldo = userDoc['saldoSimulado'] ?? 0.0;

      if (saldo >= 80.0) {
        await firestore.updateSimulatedBalance(userId, 80.0, sumar: false);

        // Guarda la suscripción premium en la colección de suscripciones
        await firestore.saveSubscription(userId, {
          'plan': 'Premium',
          'fechaActivacion': Timestamp.now(),  // Guardamos la fecha de activación como Timestamp
        });

        // Actualiza la colección 'usuarios' con los campos premium y premium_expira
        final fechaExpira = Timestamp.fromDate(DateTime.now().add(Duration(days: 30)));  // Usamos Timestamp aquí
        await firestore.saveUser(userId, {
          'premium': true,
          'premium_expira': fechaExpira,  // Guardamos como Timestamp
        });

        return 'Suscripción Premium activada correctamente.';
      } else {
        return 'No tienes suficiente saldo simulado.';
      }
    } catch (e) {
      print('Error al comprar suscripción premium: $e');
      return 'Hubo un error al procesar la suscripción.';
    }
  }




}
