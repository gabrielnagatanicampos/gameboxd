import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class GameBoxdApp extends StatelessWidget {
  const GameBoxdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GameBoxd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.escuro,
      routerConfig: router,
    );
  }
}
