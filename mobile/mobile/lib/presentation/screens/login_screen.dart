import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../data/services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _documentoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _iniciarAtendimento() async {
    final cpfDigitado = _documentoController.text.trim();
    if (cpfDigitado.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String loginUrl = '${ApiService.baseUrl}/login';
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpf': cpfDigitado}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              clienteCpf: data['clienteCpf'],
              clienteNome: data['clienteNome'],
              clientePlano: data['clientePlano'],
              faturaData: data['faturaData'],
              faturaValor: data['faturaValor'],
              faturaLink: data['faturaLink'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente não encontrado ou erro de conexão'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente não encontrado ou erro de conexão'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.branco,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'DBS Telecom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.laranjaVibrante,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _documentoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'Montserrat'),
                decoration: InputDecoration(
                  labelText: 'CPF/CNPJ',
                  labelStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: AppTheme.cinzaEscuro,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppTheme.laranjaVibrante,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.laranjaVibrante,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _iniciarAtendimento,
                        child: const Text(
                          'Iniciar Atendimento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
