import 'package:flutter/material.dart';

class ConfiguracoesScreen extends StatefulWidget {
  final String clienteNome;

  const ConfiguracoesScreen({super.key, required this.clienteNome});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _notificacoesPush = true;
  bool _mensagensSms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFFF84B03),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Conta',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Meu Perfil'),
            subtitle: Text(widget.clienteNome),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Preferências',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Notificações Push'),
            activeColor: const Color(0xFFF84B03),
            value: _notificacoesPush,
            onChanged: (bool value) {
              setState(() {
                _notificacoesPush = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Mensagens SMS'),
            activeColor: const Color(0xFFF84B03),
            value: _mensagensSms,
            onChanged: (bool value) {
              setState(() {
                _mensagensSms = value;
              });
            },
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Sobre o App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Termos de Uso'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Versão do Aplicativo'),
            subtitle: const Text('1.0.0 (MVP)'),
          ),
        ],
      ),
    );
  }
}
