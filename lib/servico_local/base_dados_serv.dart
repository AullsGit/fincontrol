import 'package:hive_flutter/hive_flutter.dart';

import '../modelos/gasto.dart';
import '../modelos/meta.dart';
import '../core/constants/app_constants.dart';

class BaseDeDadosServ {
  static late Box<Gasto> _gastosBox;
  static late Box<Meta> _metasBox;

  static Future<void> init() async {
    _gastosBox = await Hive.openBox<Gasto>(AppConstants.gastosBox);
    _metasBox = await Hive.openBox<Meta>(AppConstants.metasBox);
  }


  static Future<void> salvarGasto(Gasto gasto) async {
    await _gastosBox.put(gasto.id, gasto);
  }

  static Future<void> deletarGasto(String id) async {
    await _gastosBox.delete(id);
  }

  static List<Gasto> obterTodosGastos(String uid) {
    return _gastosBox.values.where((g) => g.uid == uid).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  static List<Gasto> obterGastosPendentes() {
    return _gastosBox.values.where((g) => !g.sincronizado).toList();
  }

  static List<Gasto> obterGastosMes(String uid, DateTime mes) {
    return _gastosBox.values.where((g) {
      return g.uid == uid &&
          g.data.year == mes.year &&
          g.data.month == mes.month;
    }).toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  
  static Future<void> salvarMeta(Meta meta) async {
    await _metasBox.put(meta.id, meta);
  }

  static Future<void> deletarMeta(String id) async {
    await _metasBox.delete(id);
  }

  static List<Meta> obterTodasMetas(String uid) {
    return _metasBox.values.where((m) => m.uid == uid).toList()
      ..sort((a, b) => b.criadaEm.compareTo(a.criadaEm));
  }

  static List<Meta> obterMetasPendentes() {
    return _metasBox.values.where((m) => !m.sincronizado).toList();
  }

  static Future<void> limparDados(String uid) async {
    final gastosKeys =
    _gastosBox.keys.where((k) => _gastosBox.get(k)?.uid == uid).toList();
    await _gastosBox.deleteAll(gastosKeys);

    final metasKeys =
    _metasBox.keys.where((k) => _metasBox.get(k)?.uid == uid).toList();
    await _metasBox.deleteAll(metasKeys);
  }
}
