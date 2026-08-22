import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    return 'https://dbs-telecom.onrender.com';
  }

  Future<Map<String, dynamic>> identificarCliente(String documento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/identificar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'documento': documento}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Cliente não encontrado');
    }
  }

  Future<Map<String, dynamic>> enviarMensagemChat(String clienteId, String mensagem, String contexto) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cliente_id': clienteId,
        'mensagem': mensagem,
        'contexto': contexto,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao enviar mensagem');
    }
  }
}
