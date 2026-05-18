import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/gastos_provider.dart';
import '../providers/metas_provider.dart';
import '../widgets/cartao_resumo_mes.dart';
import '../widgets/cartao_transacao.dart';
import '../widgets/grafico_despesas.dart';
import 'tela_gastos.dart';

class TelaInicio extends ConsumerWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final stats = ref.watch(estatisticasMesProvider);
    final gastos = ref.watch(gastosMesProvider);
    final mes = ref.watch(mesSelecionadoProvider);
    final metas = ref.watch(metasLocalProvider);

    final nomeUtilizador = authState.whenOrNull(
      data: (u) => u?.displayName ?? 'Utilizador',
    ) ??
        'Utilizador';

    final primeiroNome = nomeUtilizador.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // Header com saldo
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.goldAccent,
                        radius: 20,
                        child: Text(
                          primeiroNome.isNotEmpty
                              ? primeiroNome[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Olá, $primeiroNome 👋',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          const Text('FinControl',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      const Spacer(),
                      // Selector de mês
                      GestureDetector(
                        onTap: () => _selecionarMes(context, ref, mes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(AppFormatters.formatMonthShort(mes),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text('SALDO DISPONÍVEL',
                      style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatMZN(stats['saldo'] ?? 0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green, size: 14),
                      Text(
                        ' Rendimento: ${AppFormatters.formatMZN(stats['rendimentos'] ?? 0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(
                        child: _CartaoBrief(
                          label: '+DESPESAS',
                          valor: AppFormatters.formatMZN(stats['despesas'] ?? 0),
                          cor: AppTheme.dangerRed,
                          icone: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CartaoBrief(
                          label: 'RENDIMENTO',
                          valor: AppFormatters.formatMZN(stats['rendimentos'] ?? 0),
                          cor: AppTheme.successGreen,
                          icone: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Resumo do mês
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Text('RESUMO DO MÊS',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(letterSpacing: 1.5, color: Colors.grey)),
            ),
          ),

          // Gráfico de despesas
          if (gastos.any((g) => g.ehDespesa))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GraficoDespesas(),
                  ),
                ),
              ),
            ),

          // Metas em destaque
          if (metas.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Metas Activas',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${metas.length} metas',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: metas.take(4).length,
                  itemBuilder: (context, i) {
                    final meta = metas[i];
                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meta.nome,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          LinearProgressIndicator(
                            value: meta.progresso,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                                meta.concluida ? AppTheme.successGreen : AppTheme.accentBlue),
                          ),
                          const SizedBox(height: 4),
                          Text('${meta.percentagem.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Transações recentes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transacções Recentes',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver tudo'),
                  ),
                ],
              ),
            ),
          ),

          if (gastos.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Sem transacções este mês',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: CartaoTransacao(gasto: gastos[i]),
                ),
                childCount: gastos.take(5).length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _selecionarMes(BuildContext context, WidgetRef ref, DateTime actual) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Seleccionar mês',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      ref.read(mesSelecionadoProvider.notifier).state =
          DateTime(picked.year, picked.month);
    }
  }
}

class _CartaoBrief extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;
  final IconData icone;

  const _CartaoBrief({
    required this.label,
    required this.valor,
    required this.cor,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 4),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}