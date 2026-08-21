class ChatEngine:
    @classmethod
    def classificar_intencao(cls, message: str) -> dict:
        lower_message = message.lower()
        if any(kw in lower_message for kw in ["continua", "não resolveu", "nao resolveu", "já fiz", "ja fiz", "já reiniciei", "ja reiniciei", "sim, persiste", "sim"]):
            return {
                "setor": "suporte",
                "resposta": "Certo. Como os procedimentos iniciais não resolveram, estou encaminhando seu atendimento para a fila do Suporte Técnico.",
                "acao": "transferir_humano"
            }
        elif any(kw in lower_message for kw in ["internet lenta", "caindo", "suporte", "sem internet", "internet"]):
            return {
                "setor": "suporte",
                "resposta": "Verifique se ocorre em mais de um dispositivo, cheque os cabos e reinicie o roteador. O problema persiste após esses passos?",
                "acao": "aguardando_teste"
            }
        elif "financeiro" in lower_message or "boleto" in lower_message:
            return {
                "setor": "financeiro",
                "resposta": "Encaminhando para o setor financeiro...",
                "acao": "buscar_boleto" if "boleto" in lower_message else "nenhuma"
            }
        elif any(kw in lower_message for kw in ["comercial", "plano", "contratar", "assinar", "upgrade", "comprar"]):
            return {
                "setor": "comercial",
                "resposta": "Que ótimo ter você aqui! Será um prazer ajudar com os planos.\n\nTemos duas ótimas opções principais:\n- SEJA DBS 400MB por R$ 109,90\n- IDEAL DBS 500MB por R$ 119,90\n\nSe você tiver mais de 8 aparelhos em casa, recomendamos nossos planos com tecnologia Wi-Fi 6 para máxima estabilidade!\n\nNos planos com fidelidade de 12 meses, a ativação é totalmente grátis! (Sem fidelidade, taxa de R$ 600,00)\n\nVou transferir você agora mesmo para um de nossos consultores comerciais para escolhermos o melhor pacote!",
                "acao": "transferir_humano"
            }
        else:
            return {
                "setor": "nenhum",
                "resposta": "Olá! Como posso ajudar? Digite 'suporte', 'financeiro' ou 'comercial'.",
                "acao": "nenhuma"
            }
