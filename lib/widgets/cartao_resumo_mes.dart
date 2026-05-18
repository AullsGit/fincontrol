import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../providers/gastos_provider.dart';

class CartaoResumoMes extends ConsumerWidget {
  const CartaoResumoMes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(estatisticasMesProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo do Mês',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ItemResumo(
                    label: 'Receitas',
                    valor: AppFormatters.formatMZN(stats['rendimentos'] ?? 0),
                    cor: AppTheme.successGreen,
                    icone: Icons.arrow_upward_rounded,
                  ),
                ),
                Container(
                    height: 40, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: _ItemResumo(
                    label: 'Despesas',
                    valor: AppFormatters.formatMZN(stats['despesas'] ?? 0),
                    cor: AppTheme.dangerRed,
                    icone: Icons.arrow_downward_rounded,
                  ),
                ),
                Container(
                    height: 40, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: _ItemResumo(
                    label: 'Saldo',
                    valor: AppFormatters.formatMZN(stats['saldo'] ?? 0),
                    cor: (stats['saldo'] ?? 0) >= 0
                        ? AppTheme.accentBlue
                        : AppTheme.dangerRed,
                    icone: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemResumo extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;
  final IconData icone;

  const _ItemResumo({
    required this.label,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(valor,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: cor),
            textAlign: TextAlign.center),
      ],
    );
  }
}