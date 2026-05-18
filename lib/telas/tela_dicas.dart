import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../core/theme/app_theme.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/dicas_provider.dart';
import '../providers/gastos_provider.dart';
import '../core/utils/app_formatters.dart';

class TelaDicas extends ConsumerWidget {
  const TelaDicas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dicas = ref.watch(dicasProvider);
    final feitasIds = ref.watch(dicasFeitasProvider);
    final progresso = feitasIds.length / (dicas.isEmpty ? 1 : dicas.length);
    final stats = ref.watch(estatisticasMesProvider);
    final authState = ref.watch(authStateProvider);

    final nomeUtilizador = authState.whenOrNull(
      data: (u) => u?.displayName?.split(' ').first ?? 'Utilizador',
    ) ??
        'Utilizador';

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            title: const Text('Dicas Financeiras'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Olá, $nomeUtilizador!',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              const Text('O seu progresso financeiro',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              _MiniStat(
                                  label: 'Saldo',
                                  valor: AppFormatters.formatMZN(
                                      stats['saldo'] ?? 0)),
                              _MiniStat(
                                  label: 'Despesas',
                                  valor: AppFormatters.formatMZN(
                                      stats['despesas'] ?? 0)),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 52,
                          lineWidth: 8,
                          percent: progresso.clamp(0.0, 1.0),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(progresso * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              const Text('concluído',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 9)),
                            ],
                          ),
                          progressColor: AppTheme.goldAccent,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text('PROGRESSO GERAL',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(letterSpacing: 1.5, color: Colors.grey)),
                  const Spacer(),
                  Text('${feitasIds.length}/${dicas.length} concluídas',
                      style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final dica = dicas[i];
                final feita = feitasIds.contains(dica.id);
                return _CartaoDica(
                  dica: dica,
                  feita: feita,
                  onToggle: () => ref
                      .read(dicasFeitasProvider.notifier)
                      .toggleDica(dica.id),
                );
              },
              childCount: dicas.length,
            ),
          ),

          // Perfil / Sair
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Conta',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(nomeUtilizador),
                        subtitle: authState.whenOrNull(
                            data: (u) => Text(u?.email ?? '')),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: AppTheme.dangerRed),
                        title: const Text('Terminar Sessão',
                            style: TextStyle(color: AppTheme.dangerRed)),
                        onTap: () => _confirmarSair(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Future<void> _confirmarSair(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Terminar Sessão'),
        content: const Text('Tem a certeza que quer sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
              child: const Text('Sair')),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).sair();
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String valor;
  const _MiniStat({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
          Text(valor,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _CartaoDica extends StatelessWidget {
  final dynamic dica;
  final bool feita;
  final VoidCallback onToggle;

  const _CartaoDica({
    required this.dica,
    required this.feita,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: ListTile(
          leading: Text(dica.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(
            dica.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              decoration: feita ? TextDecoration.lineThrough : null,
              color: feita ? Colors.grey : null,
            ),
          ),
          subtitle: feita
              ? null
              : Text(dica.descricao,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          trailing: GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: feita
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                feita ? 'Feito' : 'A fazer',
                style: TextStyle(
                  color: feita ? AppTheme.successGreen : AppTheme.warningOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}