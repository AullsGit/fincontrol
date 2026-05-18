import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GastosServ {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  Future<void> adicionarGasto(String titulo, double valor) async {
    await _db.collection('gastos').add({
      'titulo': titulo,
      'valor': valor,
      'data': DateTime.now(),
      'userId': _userId,
    });
  }

  Stream<QuerySnapshot> listarGastos() {
    return _db
        .collection('gastos')
        .where('userId', isEqualTo: _userId)
        .orderBy('data', descending: true)
        .snapshots();
  }
}