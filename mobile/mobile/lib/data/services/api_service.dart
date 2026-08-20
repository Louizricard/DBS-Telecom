import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    } catch (_) {}
    return 'http://127.0.0.1:8000/api';
  }

  Future<Map<String, dynamic>> identificarCliente(String documento) async {
    final response = await http.post(
      Uri.parse('$baseUrl/identificar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'documento': documento}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Cliente não encontrado');
    }
  }

  Future<Map<String, dynamic>> enviarMensagemChat(String clienteId, String mensagem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cliente_id': clienteId,
        'mensagem': mensagem,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao enviar mensagem');
    }
  }
}
