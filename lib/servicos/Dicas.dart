import '../modelos/dica.dart';
import '../modelos/gasto.dart';

class DicasServ {
 
  List<Dica> obterDicasPersonalizadas(List<Gasto> gastos) {
    final dicas = List<Dica>.from(dicasPadrao);

    if (gastos.isEmpty) return dicas;

    final despesas = gastos.where((g) => g.ehDespesa).toList();
    final rendimentos = gastos.where((g) => !g.ehDespesa).toList();

    final totalDespesas =
    despesas.fold<double>(0, (sum, g) => sum + g.valor);
    final totalRendimentos =
    rendimentos.fold<double>(0, (sum, g) => sum + g.valor);

    final List<Dica> personalizadas = [];

   
    if (totalRendimentos > 0 && totalDespesas / totalRendimentos > 0.8) {
      personalizadas.add(const Dica(
        id: 'custom_1',
        titulo: '⚠️ Os seus gastos estão muito altos!',
        descricao:
        'Está a gastar mais de 80% do seu rendimento. Revise as suas despesas e corte o desnecessário.',
        categoria: 'gastos',
        emoji: '🚨',
      ));
    }

  
    final Map<String, double> porCategoria = {};
    for (final g in despesas) {
      porCategoria[g.categoria] =
          (porCategoria[g.categoria] ?? 0) + g.valor;
    }

    if (porCategoria.isNotEmpty) {
      final dominante = porCategoria.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      if (dominante.value / totalDespesas > 0.4) {
        personalizadas.add(Dica(
          id: 'custom_2',
          titulo: 'Atenção: ${dominante.key} representa muito',
          descricao:
          '${dominante.key} representa mais de 40% das suas despesas. Considere reduzir gastos nesta categoria.',
          categoria: 'gastos',
          emoji: '📌',
        ));
      }
    }

    return [...personalizadas, ...dicas];
  }

  double calcularProgressoGeral(List<Dica> dicas) {
    if (dicas.isEmpty) return 0;
    final feitas = dicas.where((d) => d.feita).length;
    return feitas / dicas.length;
  }
}
