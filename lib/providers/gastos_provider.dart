import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/gasto.dart';
import '../servicos/firestore_serv.dart';
import '../servicos/sincronizacao_serv.dart';
import '../servico_local/base_dados_serv.dart';
import 'autenticacao_provider.dart';

// ================= SERVICES =================

final firestoreServProvider =
Provider<FirestoreServ>((ref) => FirestoreServ());

final sincronizacaoServProvider =
Provider<SincronizacaoServ>((ref) => SincronizacaoServ());


// ================= FILTRO MÊS =================

final mesSelecionadoProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});


// ================= FIREBASE STREAM =================

final gastosStreamProvider = StreamProvider<List<Gasto>>((ref) {
  final auth = ref.watch(authStateProvider);

  return auth.when(
    data: (user) {
      if (user == null) {
        return Stream.value([]);
      }

      return ref
          .read(firestoreServProvider)
          .streamGastos(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});


// ================= GASTOS LOCAIS DO MÊS =================

final gastosMesProvider = Provider<List<Gasto>>((ref) {
  final auth = ref.watch(authStateProvider);
  final mes = ref.watch(mesSelecionadoProvider);

  return auth.when(
    data: (user) {
      if (user == null) return [];

      return BaseDeDadosServ.obterGastosMes(
        user.uid,
        mes,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});


// ================= ESTATÍSTICAS =================

final estatisticasMesProvider =
Provider<Map<String, double>>((ref) {

  final gastos = ref.watch(gastosMesProvider);

  double totalDespesas = 0;
  double totalRendimentos = 0;

  for (final g in gastos) {
    if (g.ehDespesa) {
      totalDespesas += g.valor;
    } else {
      totalRendimentos += g.valor;
    }
  }

  return {
    'despesas': totalDespesas,
    'rendimentos': totalRendimentos,
    'saldo': totalRendimentos - totalDespesas,
  };
});


// ================= DESPESAS POR CATEGORIA =================

final despesasPorCategoriaProvider =
Provider<Map<String, double>>((ref) {

  final gastos = ref.watch(gastosMesProvider);

  final Map<String, double> categorias = {};

  for (final gasto in gastos.where((g) => g.ehDespesa)) {
    categorias[gasto.categoria] =
        (categorias[gasto.categoria] ?? 0) +
            gasto.valor;
  }

  return Map.fromEntries(
    categorias.entries.toList()
      ..sort(
            (a, b) => b.value.compareTo(a.value),
      ),
  );
});


// ================= CRUD GASTOS =================

class GastosNotifier
    extends StateNotifier<AsyncValue<void>> {

  final Ref ref;

  GastosNotifier(this.ref)
      : super(const AsyncData(null));

  Future<bool> adicionarGasto(
      Gasto gasto,
      ) async {

    state = const AsyncLoading();

    try {

      final sync =
      ref.read(sincronizacaoServProvider);

      await sync.adicionarGasto(
        gasto.uid,
        gasto,
      );

      ref.invalidate(gastosMesProvider);

      state = const AsyncData(null);

      return true;

    } catch (e, stack) {

      state = AsyncError(
        e,
        stack,
      );

      return false;
    }
  }

  Future<bool> deletarGasto(
      String uid,
      String gastoId,
      ) async {

    state = const AsyncLoading();

    try {

      await BaseDeDadosServ
          .deletarGasto(gastoId);

      await ref
          .read(firestoreServProvider)
          .deletarGasto(
        uid,
        gastoId,
      );

      ref.invalidate(
        gastosMesProvider,
      );

      state = const AsyncData(null);

      return true;

    } catch (e, stack) {

      state = AsyncError(
        e,
        stack,
      );

      return false;
    }
  }
}


// ================= PROVIDER =================

final gastosNotifierProvider =
StateNotifierProvider<
    GastosNotifier,
    AsyncValue<void>>((ref) {

  return GastosNotifier(ref);

});