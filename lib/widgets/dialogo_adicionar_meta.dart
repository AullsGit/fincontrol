import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../modelos/meta.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/metas_provider.dart';

class DialogoAdicionarMeta extends ConsumerStatefulWidget {
  const DialogoAdicionarMeta({super.key});

  @override
  ConsumerState<DialogoAdicionarMeta> createState() =>
      _DialogoAdicionarMetaState();
}

class _DialogoAdicionarMetaState extends ConsumerState<DialogoAdicionarMeta> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  DateTime _prazo = DateTime.now().add(const Duration(days: 30));
  String _emojiSeleccionado = '🎯';
  bool _loading = false;

  final List<String> _emojis = [
    '🎯', '🏠', '📱', '🚗', '✈️', '🎓', '💍', '🏋️', '💻', '🌍',
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authStateProvider);
    final user = auth.whenOrNull(data: (u) => u);
    if (user == null) return;

    setState(() => _loading = true);

    final meta = Meta(
      uid: user.uid,
      nome: _nomeCtrl.text.trim(),
      valorAlvo: double.parse(_valorCtrl.text.replaceAll(',', '.')),
      prazo: _prazo,
      emoji: _emojiSeleccionado,
    );

    final sucesso =
    await ref.read(metasNotifierProvider.notifier).adicionarMeta(meta);

    setState(() => _loading = false);

    if (sucesso && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Meta criada com sucesso! 🎯'),
        backgroundColor: AppTheme.successGreen,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasRestantes = _prazo.difference(DateTime.now()).inDays;
    final valorMensal = _valorCtrl.text.isNotEmpty && diasRestantes > 0
        ? (double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0) /
        (diasRestantes / 30)
        : 0.0;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Nova Meta de Poupança',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Seletor de emoji
              Text('Ícone da meta',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  itemBuilder: (context, i) {
                    final emoji = _emojis[i];
                    final seleccionado = emoji == _emojiSeleccionado;
                    return GestureDetector(
                      onTap: () => setState(() => _emojiSeleccionado = emoji),
                      child: Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? AppTheme.accentBlue.withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: seleccionado
                              ? Border.all(color: AppTheme.accentBlue, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Nome
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome da meta',
                  hintText: 'Ex: Novo telemóvel, Férias...',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Insira o nome' : null,
              ),
              const SizedBox(height: 14),

              // Valor alvo
              TextFormField(
                controller: _valorCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor alvo (MZN)',
                  prefixText: 'MZN ',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Insira o valor';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Prazo
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _prazo,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 1825)),
                    helpText: 'Seleccionar prazo da meta',
                  );
                  if (picked != null) setState(() => _prazo = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prazo',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          Text(
                              '${_prazo.day.toString().padLeft(2, '0')}/${_prazo.month.toString().padLeft(2, '0')}/${_prazo.year} ($diasRestantes dias)',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cálculo automático
              if (valorMensal > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined,
                          color: AppTheme.accentBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Precisa de poupar ~MZN ${valorMensal.toStringAsFixed(0)}/mês para atingir esta meta a tempo.',
                          style: const TextStyle(
                              color: AppTheme.accentBlue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                      : const Text('Criar Meta'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}