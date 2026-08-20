class ChatEngine:
    @classmethod
    def classificar_intencao(cls, message: str) -> dict:
        """
        Lógica de regras/palavras-chave (Comercial, Suporte, Financeiro)
        """
        lower_message = message.lower()
        if "financeiro" in lower_message or "boleto" in lower_message:
            acao = "buscar_boleto" if "boleto" in lower_message else "nenhuma"
            return {
                "setor": "financeiro",
                "resposta": "Encaminhando para o setor financeiro...",
                "acao": acao
            }
        elif "suporte" in lower_message or "internet" in lower_message:
            return {
                "setor": "suporte",
                "resposta": "Encaminhando para o suporte técnico...",
                "acao": "nenhuma"
            }
        elif "comercial" in lower_message or "plano" in lower_message:
            return {
                "setor": "comercial",
                "resposta": "Encaminhando para o setor comercial...",
                "acao": "nenhuma"
            }
        else:
            return {
                "setor": "nenhum",
                "resposta": "Olá! Como posso ajudar? Digite 'suporte', 'financeiro' ou 'comercial'.",
                "acao": "nenhuma"
            }
