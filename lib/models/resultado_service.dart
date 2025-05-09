import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultadoService {
  static Future<void> guardarPuntos(int puntos) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final coinsGanados = puntos * 10;

    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'saldoSimulado': FieldValue.increment(coinsGanados),
    }, SetOptions(merge: true));
  }
}
