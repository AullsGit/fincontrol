import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../providers/gastos_provider.dart';

class GraficoDespesas extends ConsumerStatefulWidget {
  const GraficoDespesas({super.key});

  @override
  ConsumerState<GraficoDespesas> createState() => _GraficoDespesasState();
}

class _GraficoDespesasState extends ConsumerState<GraficoDespesas> {
  int _seccaoTocada = -1;

  static const List<Color> _cores = [
    AppTheme.accentBlue,
    AppTheme.goldAccent,
    AppTheme.successGreen,
    AppTheme.dangerRed,
    AppTheme.warningOrange,
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
    Color(0xFF6B7280),
  ];

  @override
  Widget build(BuildContext context) {
    final porCategoria = ref.watch(despesasPorCategoriaProvider);

    if (porCategoria.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Sem despesas registadas', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final total = porCategoria.values.fold(0.0, (a, b) => a + b);
    final entradas = porCategoria.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribuição de Despesas',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _seccaoTocada = -1;
                          return;
                        }
                        _seccaoTocada =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(entradas.length, (i) {
                    final isTouched = i == _seccaoTocada;
                    final percentagem = entradas[i].value / total * 100;
                    return PieChartSectionData(
                      color: _cores[i % _cores.length],
                      value: entradas[i].value,
                      title: isTouched
                          ? '${percentagem.toStringAsFixed(1)}%'
                          : '',
                      radius: isTouched ? 30 : 25,
                      titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: List.generate(
                  entradas.length,
                      (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _cores[i % _cores.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${AppConstants.categoryEmojis[entradas[i].key] ?? ''} ${entradas[i].key}',
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AppFormatters.formatMZN(entradas[i].value),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}