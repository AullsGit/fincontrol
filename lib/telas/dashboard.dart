import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/autenticacao_provider.dart';
import '../providers/sincronizacao_provider.dart';
import 'tela_inicio.dart';
import 'tela_gastos.dart';
import 'tela_metas.dart';
import 'tela_dicas.dart';
import 'tela_login.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int _paginaActual = 0;

  final _paginas = const [
    TelaInicio(),
    TelaGastos(),
    TelaMetas(),
    TelaDicas(),
  ];

  @override
  void initState() {
    super.initState();
  
    Future.microtask(
            () => ref.read(sincronizacaoNotifierProvider.notifier).sincronizar());
  }

  @override
  Widget build(BuildContext context) {
 
    ref.listen(authStateProvider, (_, next) {
      next.whenData((user) {
        if (user == null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaLogin()),
                (_) => false,
          );
        }
      });
    });

    final estaSincronizando = ref.watch(sincronizacaoNotifierProvider);
    final temInternet = ref.watch(temInternetProvider);

    return Scaffold(
      body: Column(
        children: [
         
          if (!temInternet)
            Container(
              width: double.infinity,
              color: AppTheme.warningOrange,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text('Modo offline — os dados serão sincronizados quando houver internet',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        
          if (estaSincronizando && temInternet)
            Container(
              width: double.infinity,
              color: AppTheme.successGreen,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                  SizedBox(width: 6),
                  Text('Sincronizando...',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          Expanded(child: _paginas[_paginaActual]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (i) => setState(() => _paginaActual = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Despesas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_outline_rounded),
              activeIcon: Icon(Icons.star_rounded),
              label: 'Metas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
