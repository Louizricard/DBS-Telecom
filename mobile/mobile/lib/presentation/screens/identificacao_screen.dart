import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';
import 'chat_screen.dart';

class IdentificacaoScreen extends StatefulWidget {
  const IdentificacaoScreen({super.key});

  @override
  State<IdentificacaoScreen> createState() => _IdentificacaoScreenState();
}

class _IdentificacaoScreenState extends State<IdentificacaoScreen> {
  final TextEditingController _documentoController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _iniciarAtendimento() async {
    final documento = _documentoController.text.trim();
    if (documento.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resultado = await _apiService.identificarCliente(documento);
      
      if (!mounted) return;

      final clienteId = resultado['cliente_id'].toString();
      final nome = resultado['nome'].toString();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            clienteId: clienteId,
            nome: nome,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Exibe a mensagem de erro real para ajudar no diagnóstico
      String errorMessage = 'Erro de conexão: Não foi possível acessar o servidor.';
      if (e.toString().contains('Cliente não encontrado')) {
        errorMessage = 'Cliente não encontrado na base de dados.';
      } else {
        errorMessage = 'Erro no servidor: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
