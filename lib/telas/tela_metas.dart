import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../modelos/meta.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/metas_provider.dart';
import '../widgets/dialogo_adicionar_meta.dart';

class TelaMetas extends ConsumerWidget {
  const TelaMetas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metas = ref.watch(metasLocalProvider);
    final authState = ref.watch(authStateProvider);

    final ativas = metas.where((m) => !m.concluida).toList();
    final concluidas = metas.where((m) => m.concluida).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Metas — ${metas.length} activas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogoNovaMeta(context, ref),
        backgroundColor: AppTheme.accentBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('+ Adicionar Nova Meta',
            style: TextStyle(color: Colors.white)),
      ),
      body: metas.isEmpty
          ? _EmptyMetas(onAdicionar: () => _abrirDialogoNovaMeta(context, ref))
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          if (ativas.isNotEmpty) ...[
            _SectionHeader(
                titulo: 'Em progresso', quantidade: ativas.length),
            const SizedBox(height: 12),
            ...ativas.map((meta) => _CartaoMeta(
              meta: meta,
              onDelete: () => _deletarMeta(context, ref, meta),
              onAtualizar: () =>
                  _atualizarProgresso(context, ref, meta),
            )),
          ],
          if (concluidas.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionHeader(
                titulo: 'Concluídas ✅', quantidade: concluidas.length),
            const SizedBox(height: 12),
            ...concluidas.map((meta) => _CartaoMeta(
              meta: meta,
              concluida: true,
              onDelete: () => _deletarMeta(context, ref, meta),
              onAtualizar: () {},
            )),
          ],
        ],
      ),
    );
  }

  void _abrirDialogoNovaMeta(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DialogoAdicionarMeta(),
    );
  }

  Future<void> _deletarMeta(
      BuildContext context, WidgetRef ref, Meta meta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: Text('Eliminar a meta "${meta.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.dangerRed),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      final auth = ref.read(authStateProvider);
      auth.whenData((user) async {
        if (user != null) {
          await ref
              .read(metasNotifierProvider.notifier)
              .deletarMeta(user.uid, meta.id);
        }
      });
    }
  }

  Future<void> _atualizarProgresso(
      BuildContext context, WidgetRef ref, Meta meta) async {
    final ctrl =
    TextEditingController(text: meta.valorActual.toStringAsFixed(0));
    final resultado = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Actualizar "${meta.nome}"'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Valor actual poupado (MZN)',
            prefixIcon: Icon(Icons.savings_outlined),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                if (v != null) Navigator.pop(context, v);
              },
              child: const Text('Guardar')),
        ],
      ),
    );

    if (resultado != null) {
      await ref
          .read(metasNotifierProvider.notifier)
          .atualizarProgresso(meta, resultado);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String titulo;
  final int quantidade;

  const _SectionHeader({required this.titulo, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(titulo,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$quantidade',
              style: const TextStyle(
                  color: AppTheme.accentBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _CartaoMeta extends StatelessWidget {
  final Meta meta;
  final bool concluida;
  final VoidCallback onDelete;
  final VoidCallback onAtualizar;

  const _CartaoMeta({
    required this.meta,
    this.concluida = false,
    required this.onDelete,
    required this.onAtualizar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = concluida
        ? AppTheme.successGreen
        : meta.percentagem >= 80
        ? AppTheme.warningOrange
        : AppTheme.accentBlue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(meta.emoji ?? '🎯', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(meta.nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (!concluida)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppTheme.accentBlue, size: 22),
                    onPressed: onAtualizar,
                    tooltip: 'Actualizar progresso',
                  ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.grey.shade400, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 10,
              percent: meta.progresso,
              backgroundColor: Colors.grey.shade200,
              progressColor: cor,
              barRadius: const Radius.circular(6),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppFormatters.formatMZN(meta.valorActual)} / ${AppFormatters.formatMZN(meta.valorAlvo)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${meta.percentagem.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cor),
                ),
              ],
            ),
            if (!concluida && meta.diasRestantes > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${meta.diasRestantes} dias restantes',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    'Poupar ${AppFormatters.formatMZN(meta.valorDiarioNecessario)}/dia',
                    style: TextStyle(
                        fontSize: 11,
                        color: cor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            if (concluida)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successGreen, size: 14),
                    SizedBox(width: 4),
                    Text('Meta concluída! 🎉',
                        style: TextStyle(
                            color: AppTheme.successGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMetas extends StatelessWidget {
  final VoidCallback onAdicionar;
  const _EmptyMetas({required this.onAdicionar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Nenhuma meta ainda',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Defina objectivos financeiros e acompanhe o seu progresso',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeira Meta'),
            ),
          ],
        ),
      ),
    );
  }
}