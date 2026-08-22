import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../data/services/api_service.dart';

class ContratosScreen extends StatefulWidget {
  final String cpf;

  const ContratosScreen({super.key, required this.cpf});

  @override
  State<ContratosScreen> createState() => _ContratosScreenState();
}

class _ContratosScreenState extends State<ContratosScreen> {
  bool _isLoading = true;
  List<dynamic> _contratos = [];

  @override
  void initState() {
    super.initState();
    _fetchContratos();
  }

  Future<void> _fetchContratos() async {
    try {
      final String contratosUrl = '${ApiService.baseUrl}/contratos/${widget.cpf}';
      final response = await http.get(Uri.parse(contratosUrl));

      if (response.statusCode == 200) {
        setState(() {
          _contratos = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _pegarCorStatus(String status) {
    if (status.toLowerCase() == 'ativo') return Colors.green;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Contratos'),
        backgroundColor: const Color(0xFFF84B03),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF84B03)),
              ),
            )
          : _contratos.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum contrato encontrado',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contratos.length,
                  itemBuilder: (context, index) {
                    final contrato = _contratos[index];
                    final plano = contrato['plano'] ?? 'Desconhecido';
                    final status = contrato['status'] ?? 'desconhecido';
                    final dataAtivacao = contrato['data_ativacao'] ?? 'N/A';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Color(0xFFF84B03),
                        ),
                        title: Text(
                          plano,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B4C51),
                          ),
                        ),
                        subtitle: Text(
                          'Status: ${status.toUpperCase()}\nAtivação: $dataAtivacao',
                          style: TextStyle(
                            color: _pegarCorStatus(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
