import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../modelos/gasto.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/gastos_provider.dart';

class DialogoAdicionarGasto extends ConsumerStatefulWidget {
  const DialogoAdicionarGasto({super.key});

  @override
  ConsumerState<DialogoAdicionarGasto> createState() =>
      _DialogoAdicionarGastoState();
}

class _DialogoAdicionarGastoState
    extends ConsumerState<DialogoAdicionarGasto> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  bool _ehDespesa = true;
  String _categoriaSeleccionada = AppConstants.categoriasDespesas.first;
  String _fonteSeleccionada = AppConstants.fontesRendimento.first;
  DateTime _data = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _valorCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authStateProvider);
    final user = auth.whenOrNull(data: (u) => u);
    if (user == null) return;

    setState(() => _loading = true);

    final gasto = Gasto(
      uid: user.uid,
      valor: double.parse(_valorCtrl.text.replaceAll(',', '.')),
      categoria:
      _ehDespesa ? _categoriaSeleccionada : _fonteSeleccionada,
      descricao: _descricaoCtrl.text.trim(),
      data: _data,
      ehDespesa: _ehDespesa,
      fonte: _ehDespesa ? null : _fonteSeleccionada,
    );

    final sucesso = await ref
        .read(gastosNotifierProvider.notifier)
        .adicionarGasto(gasto);

    setState(() => _loading = false);

    if (sucesso && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${_ehDespesa ? 'Despesa' : 'Rendimento'} registado com sucesso!'),
        backgroundColor: AppTheme.successGreen,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Handle
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
              Text('Registar Transacção',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Toggle Despesa / Rendimento
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _ehDespesa = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _ehDespesa
                                ? AppTheme.dangerRed
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('💸 Despesa',
                                style: TextStyle(
                                    color: _ehDespesa
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _ehDespesa = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_ehDespesa
                                ? AppTheme.successGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('💰 Rendimento',
                                style: TextStyle(
                                    color: !_ehDespesa
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Valor
              TextFormField(
                controller: _valorCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor (MZN)',
                  prefixText: 'MZN ',
                  prefixIcon: Icon(
                    Icons.attach_money_rounded,
                    color: _ehDespesa
                        ? AppTheme.dangerRed
                        : AppTheme.successGreen,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Insira o valor';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Categoria / Fonte
              DropdownButtonFormField<String>(
                value: _ehDespesa
                    ? _categoriaSeleccionada
                    : _fonteSeleccionada,
                decoration: InputDecoration(
                  labelText: _ehDespesa ? 'Categoria' : 'Fonte de Rendimento',
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: (_ehDespesa
                    ? AppConstants.categoriasDespesas
                    : AppConstants.fontesRendimento)
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(
                      '${AppConstants.categoryEmojis[cat] ?? '📦'} $cat'),
                ))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    if (_ehDespesa) {
                      _categoriaSeleccionada = v;
                    } else {
                      _fonteSeleccionada = v;
                    }
                  });
                },
              ),
              const SizedBox(height: 14),

              // Descrição
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Data
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _data = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text(
                          '${_data.day.toString().padLeft(2, '0')}/${_data.month.toString().padLeft(2, '0')}/${_data.year}',
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _guardar,
                  child: _loading
                      ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                      : Text(
                      'Guardar ${_ehDespesa ? 'Despesa' : 'Rendimento'}'),
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