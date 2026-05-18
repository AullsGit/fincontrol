import 'package:connectivity_plus/connectivity_plus.dart';

import '../modelos/gasto.dart';
import '../modelos/meta.dart';
import 'firestore_serv.dart';
import '../servico_local/base_dados_serv.dart';

class SincronizacaoServ {
  final FirestoreServ _firestore = FirestoreServ();

  Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  Future<bool> temInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Future<void> sincronizar(String uid) async {
    if (!await temInternet()) return;

    // Sync gastos pendentes
    final gastosPendentes = BaseDeDadosServ.obterGastosPendentes();
    if (gastosPendentes.isNotEmpty) {
      await _firestore.sincronizarGastosPendentes(uid, gastosPendentes);
      for (final g in gastosPendentes) {
        g.sincronizado = true;
        await g.save();
      }
    }

    // Sync metas pendentes
    final metasPendentes = BaseDeDadosServ.obterMetasPendentes();
    for (final meta in metasPendentes) {
      await _firestore.adicionarMeta(meta);
      meta.sincronizado = true;
      await meta.save();
    }
  }

  Future<void> adicionarGasto(String uid, Gasto gasto) async {
    // Sempre salva local primeiro
    await BaseDeDadosServ.salvarGasto(gasto);

    // Tenta sync imediato
    if (await temInternet()) {
      await _firestore.adicionarGasto(gasto);
      gasto.sincronizado = true;
      await gasto.save();
    }
  }

  Future<void> adicionarMeta(String uid, Meta meta) async {
    await BaseDeDadosServ.salvarMeta(meta);
    if (await temInternet()) {
      await _firestore.adicionarMeta(meta);
      meta.sincronizado = true;
      await meta.save();
    }
  }
}