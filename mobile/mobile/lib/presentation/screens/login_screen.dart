import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../data/services/api_service.dart';
import 'home_screen.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 14) return oldValue;

    String formattedText = text;

    if (text.length <= 11) {
      if (text.length > 3) formattedText = '${text.substring(0, 3)}.${text.substring(3)}';
      if (text.length > 6) formattedText = '${formattedText.substring(0, 7)}.${text.substring(6)}';
      if (text.length > 9) formattedText = '${formattedText.substring(0, 11)}-${text.substring(9)}';
    } else {
      if (text.length > 2) formattedText = '${text.substring(0, 2)}.${text.substring(2)}';
      if (text.length > 5) formattedText = '${formattedText.substring(0, 6)}.${text.substring(5)}';
      if (text.length > 8) formattedText = '${formattedText.substring(0, 10)}/${text.substring(8)}';
      if (text.length > 12) formattedText = '${formattedText.substring(0, 15)}-${text.substring(12)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _documentoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _iniciarAtendimento() async {
    FocusScope.of(context).unfocus();

    if (_documentoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Por favor, preencha com seu CPF para verificar seus dados'),
        ),
      );
      return;
    }

    final cpfDigitado = _documentoController.text.trim();

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
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente não encontrado. Verifique o CPF/CNPJ digitado.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro ao processar sua solicitação. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão. Verifique sua internet e tente novamente.'),
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
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                inputFormatters: [CpfCnpjFormatter()],
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
