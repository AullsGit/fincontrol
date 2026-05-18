import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/dica.dart';
import '../servicos/Dicas.dart';
import 'gastos_provider.dart';

final dicasServProvider = Provider<DicasServ>((ref) => DicasServ());

final dicasProvider = Provider<List<Dica>>((ref) {
  final gastos = ref.watch(gastosMesProvider);
  final serv = ref.read(dicasServProvider);
  return serv.obterDicasPersonalizadas(gastos);
});

final progressoGeralProvider = Provider<double>((ref) {
  final dicas = ref.watch(dicasProvider);
  final serv = ref.read(dicasServProvider);
  return serv.calcularProgressoGeral(dicas);
});

// Estado local de dicas marcadas como feitas
final dicasFeitasProvider =
StateNotifierProvider<DicasFeitasNotifier, Set<String>>((ref) {
  return DicasFeitasNotifier();
});

class DicasFeitasNotifier extends StateNotifier<Set<String>> {
  DicasFeitasNotifier() : super({});

  void toggleDica(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool ehFeita(String id) => state.contains(id);
}