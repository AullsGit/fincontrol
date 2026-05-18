import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'modelos/gasto.dart';
import 'modelos/meta.dart';
import 'modelos/usuario.dart';
import 'servico_local/base_dados_serv.dart';
import 'telas/tela_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localização (intl)
  await initializeDateFormatting('pt_BR', null);

  // Inicializar Hive (armazenamento offline)
  await Hive.initFlutter();

  Hive.registerAdapter(GastoAdapter());
  Hive.registerAdapter(MetaAdapter());

  await BaseDeDadosServ.init();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: FinControlApp(),
    ),
  );
}

class FinControlApp extends ConsumerWidget {
  const FinControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FinControl',
      debugShowCheckedModeBanner: false,

      // Tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Idioma/localização
      locale: const Locale('pt', 'BR'),

      home: const TelaLogin(),
    );
  }
}