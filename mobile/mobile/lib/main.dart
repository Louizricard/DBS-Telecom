import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/screens/identificacao_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DBS Telecom',
      theme: AppTheme.theme,
      home: const IdentificacaoScreen(),
    );
  }
}
