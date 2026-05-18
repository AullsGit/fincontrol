import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../servicos/sincronizacao_serv.dart';
import 'autenticacao_provider.dart';
import 'gastos_provider.dart';

final conectividadeProvider =
StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final temInternetProvider = Provider<bool>((ref) {
  final conn = ref.watch(conectividadeProvider);
  return conn.when(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    loading: () => true,
    error: (_, __) => false,
  );
});

final sincronizacaoNotifierProvider =
StateNotifierProvider<SincronizacaoNotifier, bool>((ref) {
  return SincronizacaoNotifier(ref);
});

class SincronizacaoNotifier extends StateNotifier<bool> {
  final Ref _ref;

  SincronizacaoNotifier(this._ref) : super(false) {
    _observarConectividade();
  }

  void _observarConectividade() {
    _ref.listen(conectividadeProvider, (prev, next) {
      next.whenData((results) {
        final temNet = results.any((r) => r != ConnectivityResult.none);
        if (temNet) {
          sincronizar();
        }
      });
    });
  }

  Future<void> sincronizar() async {
    if (state) return; // já sincronizando
    state = true;
    try {
      final auth = _ref.read(authStateProvider);
      auth.whenData((user) async {
        if (user != null) {
          await _ref.read(sincronizacaoServProvider).sincronizar(user.uid);
          _ref.invalidate(gastosMesProvider);
        }
      });
    } finally {
      state = false;
    }
  }
}