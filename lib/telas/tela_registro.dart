import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/autenticacao_provider.dart';
import 'dashboard.dart';

class TelaRegistro extends ConsumerStatefulWidget {
  const TelaRegistro({super.key});

  @override
  ConsumerState<TelaRegistro> createState() => _TelaRegistroState();
}

class _TelaRegistroState extends ConsumerState<TelaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();
  bool _mostrarSenha = false;
  bool _loading = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _registar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await ref.read(authNotifierProvider.notifier).registar(
      nomeCompleto: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _senhaCtrl.text.trim(),
    );

    final state = ref.read(authNotifierProvider);
    setState(() => _loading = false);

    state.when(
      data: (u) {
        if (u != null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Dashboard()),
                (_) => false,
          );
        }
      },
      loading: () {},
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.dangerRed));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Novo',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Criar Conta',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nomeCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome completo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Insira o seu nome'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                            v == null || !v.contains('@') ? 'Email inválido' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senhaCtrl,
                            obscureText: !_mostrarSenha,
                            decoration: InputDecoration(
                              labelText: 'Palavra-passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_mostrarSenha
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _mostrarSenha = !_mostrarSenha),
                              ),
                            ),
                            validator: (v) =>
                            v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmarSenhaCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar senha',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) => v != _senhaCtrl.text
                                ? 'As senhas não coincidem'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _registar,
                              child: _loading
                                  ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                                  : const Text('Registar Agora'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Já tem conta? '),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Entrar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}