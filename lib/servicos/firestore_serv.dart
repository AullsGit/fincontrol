import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../modelos/gasto.dart';
import '../modelos/meta.dart';

class FirestoreServ {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===================== GASTOS =====================

  Future<void> adicionarGasto(Gasto gasto) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(gasto.uid)
        .collection(AppConstants.gastosCollection)
        .doc(gasto.id)
        .set(gasto.toMap());
  }

  Future<void> deletarGasto(String uid, String gastoId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.gastosCollection)
        .doc(gastoId)
        .delete();
  }

  Stream<List<Gasto>> streamGastos(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.gastosCollection)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Gasto.fromMap(d.data())).toList());
  }

  Future<List<Gasto>> obterGastosMes(String uid, DateTime mes) async {
    final inicio = DateTime(mes.year, mes.month, 1);
    final fim = DateTime(mes.year, mes.month + 1, 0, 23, 59, 59);

    final snap = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.gastosCollection)
        .where('data',
        isGreaterThanOrEqualTo: inicio.millisecondsSinceEpoch,
        isLessThanOrEqualTo: fim.millisecondsSinceEpoch)
        .orderBy('data', descending: true)
        .get();

    return snap.docs.map((d) => Gasto.fromMap(d.data())).toList();
  }

  // ===================== METAS =====================

  Future<void> adicionarMeta(Meta meta) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(meta.uid)
        .collection(AppConstants.metasCollection)
        .doc(meta.id)
        .set(meta.toMap());
  }

  Future<void> atualizarMeta(Meta meta) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(meta.uid)
        .collection(AppConstants.metasCollection)
        .doc(meta.id)
        .update({'valorActual': meta.valorActual});
  }

  Future<void> deletarMeta(String uid, String metaId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.metasCollection)
        .doc(metaId)
        .delete();
  }

  Stream<List<Meta>> streamMetas(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection(AppConstants.metasCollection)
        .orderBy('criadaEm', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Meta.fromMap(d.data())).toList());
  }

  // ===================== SYNC =====================

  Future<void> sincronizarGastosPendentes(
      String uid, List<Gasto> gastos) async {
    final batch = _db.batch();
    for (final gasto in gastos) {
      final ref = _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection(AppConstants.gastosCollection)
          .doc(gasto.id);
      batch.set(ref, gasto.toMap());
    }
    await batch.commit();
  }
}