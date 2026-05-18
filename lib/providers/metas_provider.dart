import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/meta.dart';
import '../servicos/sincronizacao_serv.dart';
import '../servico_local/base_dados_serv.dart';
import '../servicos/firestore_serv.dart';
import 'autenticacao_provider.dart';
import 'gastos_provider.dart';

// Stream de metas do Firebase
final metasStreamProvider = StreamProvider<List<Meta>>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.read(firestoreServProvider).streamMetas(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Metas locais
final metasLocalProvider = Provider<List<Meta>>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) {
      if (user == null) return [];
      return BaseDeDadosServ.obterTodasMetas(user.uid);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Metas notifier
class MetasNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  MetasNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> adicionarMeta(Meta meta) async {
    state = const AsyncValue.loading();
    try {
      final sync = _ref.read(sincronizacaoServProvider);
      await sync.adicionarMeta(meta.uid, meta);
      _ref.invalidate(metasLocalProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> atualizarProgresso(Meta meta, double novoValor) async {
    state = const AsyncValue.loading();
    try {
      meta.valorActual = novoValor;
      await BaseDeDadosServ.salvarMeta(meta);
      await _ref.read(firestoreServProvider).atualizarMeta(meta);
      _ref.invalidate(metasLocalProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deletarMeta(String uid, String metaId) async {
    state = const AsyncValue.loading();
    try {
      await BaseDeDadosServ.deletarMeta(metaId);
      await _ref.read(firestoreServProvider).deletarMeta(uid, metaId);
      _ref.invalidate(metasLocalProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final metasNotifierProvider =
StateNotifierProvider<MetasNotifier, AsyncValue<void>>((ref) {
  return MetasNotifier(ref);
});