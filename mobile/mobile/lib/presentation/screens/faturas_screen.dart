import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';

class FaturasScreen extends StatefulWidget {
  final String cpf;

  const FaturasScreen({super.key, required this.cpf});

  @override
  State<FaturasScreen> createState() => _FaturasScreenState();
}

class _FaturasScreenState extends State<FaturasScreen> {
  bool _isLoading = true;
  List<dynamic> _faturas = [];

  @override
  void initState() {
    super.initState();
    _fetchFaturas();
  }

  Future<void> _fetchFaturas() async {
    try {
      final String faturasUrl = '${ApiService.baseUrl}/faturas/${widget.cpf}';
      final response = await http.get(Uri.parse(faturasUrl));

      if (response.statusCode == 200) {
        setState(() {
          _faturas = jsonDecode(response.body);
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

  String _formatarData(String dataIso) {
    try {
      final partes = dataIso.split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
      return dataIso;
    } catch (e) {
      return dataIso;
    }
  }

  String _formatarValor(dynamic valor) {
    try {
      final double valorNum = double.parse(valor.toString());
      return 'R\$ ${valorNum.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ $valor';
    }
  }

  Color _pegarCorStatus(String status) {
    if (status == 'pago') return Colors.green;
    if (status == 'atrasado') return Colors.red;
    return AppTheme.laranjaVibrante;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Faturamentos'),
        backgroundColor: const Color(0xFFF84B03),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF84B03)),
              ),
            )
          : _faturas.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum histórico de faturas encontrado',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faturas.length,
                  itemBuilder: (context, index) {
                    final fatura = _faturas[index];
                    final valorStr = _formatarValor(fatura['valor']);
                    final dataStr = _formatarData(fatura['vencimento'] ?? '');
                    final status = fatura['status'] ?? 'pendente';
                    final linkBoleto = fatura['link_boleto'];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt,
                          color: Color(0xFFF84B03),
                        ),
                        title: Text(
                          valorStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Vencimento: $dataStr\nStatus: ${status.toUpperCase()}',
                          style: TextStyle(
                            color: _pegarCorStatus(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          color: const Color(0xFFF84B03),
                          onPressed: () async {
                            if (linkBoleto != null) {
                              final uri = Uri.parse(linkBoleto);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Não foi possível abrir o link do boleto.'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
