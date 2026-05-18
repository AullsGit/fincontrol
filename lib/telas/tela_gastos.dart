import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_formatters.dart';
import '../modelos/gasto.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/gastos_provider.dart';
import '../widgets/cartao_transacao.dart';
import '../widgets/dialogo_adicionar_gasto.dart';

class TelaGastos extends ConsumerStatefulWidget {
  const TelaGastos({super.key});

  @override
  ConsumerState<TelaGastos> createState() => _TelaGastosState();
}

class _TelaGastosState extends ConsumerState<TelaGastos>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gastos = ref.watch(gastosMesProvider);
    final stats = ref.watch(estatisticasMesProvider);
    final mes = ref.watch(mesSelecionadoProvider);
    final despesasPorCat = ref.watch(despesasPorCategoriaProvider);

    // Filtro
    final despesas = gastos
        .where((g) =>
    g.ehDespesa &&
        (_categoriaFiltro == null || g.categoria == _categoriaFiltro))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Despesas — ${AppFormatters.formatMonthShort(mes)}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Despesas'), Tab(text: 'Rendimentos')],
          indicatorColor: AppTheme.goldAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogoAdicionar(context),
        backgroundColor: AppTheme.accentBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Registar', style: TextStyle(color: Colors.white)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Despesas
          Column(
            children: [
              // Total do mês
              Container(
                color: AppTheme.primaryBlue,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    const Text('Total do Mês',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const Spacer(),
                    Text(AppFormatters.formatMZN(stats['despesas'] ?? 0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ),
              // Categorias chips
              if (despesasPorCat.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    children: [
                      _ChipFiltro(
                        label: 'Todas',
                        selecionado: _categoriaFiltro == null,
                        onTap: () => setState(() => _categoriaFiltro = null),
                      ),
                      ...despesasPorCat.keys.map((cat) => _ChipFiltro(
                        label:
                        '${AppConstants.categoryEmojis[cat] ?? '📦'} $cat',
                        selecionado: _categoriaFiltro == cat,
                        onTap: () =>
                            setState(() => _categoriaFiltro = cat),
                      )),
                    ],
                  ),
                ),
              // Lista de despesas
              Expanded(
                child: despesas.isEmpty
                    ? _EmptyState(tabIndex: 0)
                    : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: despesas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => CartaoTransacao(
                    gasto: despesas[i],
                    onDelete: () => _deletarGasto(despesas[i]),
                  ),
                ),
              ),
            ],
          ),
          // Tab Rendimentos
          Builder(builder: (context) {
            final rendimentos = gastos.where((g) => !g.ehDespesa).toList();
            return Column(
              children: [
                Container(
                  color: AppTheme.primaryBlue,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      const Text('Total do Mês',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      Text(AppFormatters.formatMZN(stats['rendimentos'] ?? 0),
                          style: const TextStyle(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: rendimentos.isEmpty
                      ? _EmptyState(tabIndex: 1)
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: rendimentos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => CartaoTransacao(
                      gasto: rendimentos[i],
                      onDelete: () => _deletarGasto(rendimentos[i]),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _deletarGasto(Gasto gasto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar transacção'),
        content: Text(
            'Tem a certeza que quer eliminar "${gasto.descricao}"?'),
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

    if (confirm == true && mounted) {
      final auth = ref.read(authStateProvider);
      auth.whenData((user) async {
        if (user != null) {
          await ref
              .read(gastosNotifierProvider.notifier)
              .deletarGasto(user.uid, gasto.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transacção eliminada')));
          }
        }
      });
    }
  }

  void _abrirDialogoAdicionar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DialogoAdicionarGasto(),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipFiltro(
      {required this.label,
        required this.selecionado,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selecionado ? AppTheme.accentBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selecionado ? AppTheme.accentBlue : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selecionado ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight:
            selecionado ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int tabIndex;
  const _EmptyState({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            tabIndex == 0 ? Icons.receipt_long_outlined : Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            tabIndex == 0
                ? 'Sem despesas este mês'
                : 'Sem rendimentos este mês',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Registar" para adicionar',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}