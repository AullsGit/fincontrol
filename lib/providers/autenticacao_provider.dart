import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/usuario.dart';
import '../servicos/autenticacao_serv.dart';

final autenticacaoServProvider = Provider<AutenticacaoServ>((ref) {
  return AutenticacaoServ();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(autenticacaoServProvider).authStateChanges;
});

final usuarioAtualProvider = FutureProvider<Usuario?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final serv = ref.read(autenticacaoServProvider);
      return await serv.obterPerfil(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth notifier para ações
class AuthNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  final AutenticacaoServ _serv;

  AuthNotifier(this._serv) : super(const AsyncValue.data(null));

  Future<void> registar({
    required String nomeCompleto,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final usuario =
      await _serv.registar(nomeCompleto: nomeCompleto, email: email, password: password);
      state = AsyncValue.data(usuario);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> entrar({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final usuario = await _serv.entrar(email: email, password: password);
      state = AsyncValue.data(usuario);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> recuperarSenha(String email) async {
    state = const AsyncValue.loading();
    try {
      await _serv.recuperarSenha(email);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sair() async {
    await _serv.sair();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<Usuario?>>((ref) {
  return AuthNotifier(ref.read(autenticacaoServProvider));
});