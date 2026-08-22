import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../data/services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String> sugestoes;

  ChatMessage({required this.text, required this.isUser, this.sugestoes = const []});

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'sugestoes': sugestoes,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    sugestoes: List<String>.from(json['sugestoes'] ?? []),
  );
}

class ChatScreen extends StatefulWidget {
  final String clienteId;
  final String nome;

  const ChatScreen({
    super.key,
    required this.clienteId,
    required this.nome,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _departamentoAtual = "Atendimento Inicial";
  String _contextoAtual = "";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history_${widget.clienteId}');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      setState(() {
        _messages.clear();
        _messages.addAll(decoded.map((e) => ChatMessage.fromJson(e)).toList());
      });
      _scrollToBottom();
    } else {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Olá, ${widget.nome}! 👋 Sou o assistente virtual da DBS TELECOM. Como posso ajudar você hoje?',
            isUser: false,
            sugestoes: ["Ver planos", "2ª via do boleto", "Estou sem internet"],
          ),
        );
      });
      _saveHistory();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages.map((m) => m.toJson()).toList());
    await prefs.setString('chat_history_${widget.clienteId}', encoded);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuickAction(String text) {
    _textController.text = text;
    _sendMessage();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _saveHistory();
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _apiService.enviarMensagemChat(widget.clienteId, text, _contextoAtual);
      final reply = response['resposta']?.toString() ?? 'Desculpe, ocorreu um erro ao processar a resposta.';
      final setor = response['setor']?.toString();
      final sugestoes = List<String>.from(response['sugestoes'] ?? []);

      if (mounted) {
        setState(() {
          _contextoAtual = response['contexto']?.toString() ?? "";
          _messages.add(ChatMessage(text: reply, isUser: false, sugestoes: sugestoes));
          _isLoading = false;
          if (setor == 'comercial') {
            _departamentoAtual = "Setor Comercial 🤝";
          } else if (setor == 'suporte') {
            _departamentoAtual = "Suporte Técnico 🛠️";
          } else if (setor == 'financeiro') {
            _departamentoAtual = "Setor Financeiro 💰";
          }
        });
        _saveHistory();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erro de conexão. Verifique sua internet ou tente novamente mais tarde."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = isUser ? const Color(0xFFF84B03) : const Color(0xFF4B4C51);
    final borderRadius = BorderRadius.circular(12);

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Linkify(
          onOpen: (link) async {
            await launchUrl(Uri.parse(link.url));
          },
          text: message.text,
          style: const TextStyle(
            color: AppTheme.branco,
            fontFamily: 'Montserrat',
            fontSize: 16,
          ),
          linkStyle: const TextStyle(
            color: Colors.lightBlue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ultimasDoBot = _messages.where((m) => !m.isUser);
    final sugestoesAtuais = ultimasDoBot.isNotEmpty ? ultimasDoBot.last.sugestoes : <String>[];

    return Scaffold(
      backgroundColor: AppTheme.branco,
      appBar: AppBar(
        backgroundColor: AppTheme.laranjaVibrante,
        title: Text(
          'DBS - $_departamentoAtual',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: AppTheme.branco,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.branco),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cinzaEscuro),
                  ),
                ),
              ),
            ),
          sugestoesAtuais.isNotEmpty && !_isLoading
              ? SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: sugestoesAtuais.map((sugestao) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(sugestao),
                          onPressed: () => _sendQuickAction(sugestao),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFF84B03)),
                          labelStyle: const TextStyle(
                            color: Color(0xFFF84B03),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.branco,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontFamily: 'Montserrat'),
                      decoration: InputDecoration(
                        hintText: 'Digite sua mensagem...',
                        hintStyle: const TextStyle(fontFamily: 'Montserrat'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.laranjaVibrante,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.branco),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
