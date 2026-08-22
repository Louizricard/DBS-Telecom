import logging
from datetime import datetime
from app.services.ixc_service import IXCService

logger = logging.getLogger(__name__)
ixc_service = IXCService()

class ChatEngine:
    @classmethod
    def classificar_intencao(cls, message: str, contexto: str = "", cpf_cliente: str = "") -> dict:
        lower_message = message.lower()
        
        if contexto == "verificando_dispositivos":
            if "sim" in lower_message:
                resultado = {
                    "setor": "suporte",
                    "resposta": "Você já reiniciou o roteador?",
                    "acao": "aguardando_teste",
                    "sugestoes": ["Já reiniciei", "Ainda não"],
                    "contexto": "verificando_roteador"
                }
            elif "não" in lower_message or "nao" in lower_message:
                resultado = {
                    "setor": "suporte",
                    "resposta": "Certo. Vamos focar neste aparelho. Já tentou esquecer a rede e conectar novamente?",
                    "acao": "aguardando_teste",
                    "sugestoes": ["Sim, não funcionou", "Vou tentar"],
                    "contexto": "foco_dispositivo"
                }
            else:
                resultado = {
                    "setor": "suporte",
                    "resposta": "Não entendi. O problema acontece em todos os dispositivos?",
                    "acao": "aguardando_teste",
                    "sugestoes": ["Sim", "Não"],
                    "contexto": "verificando_dispositivos"
                }
        elif contexto == "verificando_roteador":
            if any(kw in lower_message for kw in ["já reiniciei", "ja reiniciei", "sim"]):
                resultado = {
                    "setor": "suporte",
                    "resposta": "Entendi. Como o problema continua, estou encaminhando seu atendimento para o nosso Suporte Técnico avançado.",
                    "acao": "transferir_humano",
                    "sugestoes": ["Menu Principal"],
                    "contexto": ""
                }
            else:
                resultado = {
                    "setor": "suporte",
                    "resposta": "Por favor, reinicie o roteador e me avise se voltou a funcionar.",
                    "acao": "aguardando_teste",
                    "sugestoes": ["Já reiniciei", "Ainda não"],
                    "contexto": "verificando_roteador"
                }
        elif any(kw in lower_message for kw in ["continua", "não resolveu", "nao resolveu", "já fiz", "ja fiz", "já reiniciei", "ja reiniciei", "sim, persiste", "sim", "persiste", "ainda", "mesma coisa", "não funcionou"]):
            resultado = {
                "setor": "suporte",
                "resposta": "Certo. Como os procedimentos iniciais não resolveram, estou encaminhando seu atendimento para a fila do Suporte Técnico.",
                "acao": "transferir_humano",
                "sugestoes": ["Menu Principal", "Financeiro", "Comercial"],
                "contexto": ""
            }
        elif any(kw in lower_message for kw in ["internet", "ruim", "caindo", "sem"]):
            resultado = {
                "setor": "suporte",
                "resposta": "Entendi. Vou te ajudar a verificar sua conexão. 📡 Primeiro, o problema acontece em todos os dispositivos?",
                "acao": "aguardando_teste",
                "sugestoes": ["Sim", "Não"],
                "contexto": "verificando_dispositivos"
            }
        elif any(kw in lower_message for kw in ["financeiro", "boleto", "fatura", "2 via", "segunda via", "conta", "pagamento"]):
            if cpf_cliente:
                fatura = ixc_service.buscar_fatura_ixc(cpf_cliente)
                if fatura:
                    dt = datetime.strptime(fatura['vencimento'], '%Y-%m-%d').strftime('%d/%m/%Y')
                    val = f"{float(fatura['valor']):,.2f}".replace(',', 'X').replace('.', ',').replace('X', '.')
                    resposta = f"Encontrei seu boleto no valor de R$ {val} com vencimento para {dt}. Você pode acessá-lo aqui: {fatura['link_boleto']}"
                else:
                    resposta = "Consultei o sistema, mas não encontrei nenhum boleto em aberto para o seu cadastro no momento."
            else:
                resposta = "Encaminhando para o setor financeiro..."
                
            resultado = {
                "setor": "financeiro",
                "resposta": resposta,
                "acao": "nenhuma",
                "sugestoes": ["Menu Principal", "Falar com Suporte", "Ver planos"],
                "contexto": ""
            }
        elif any(kw in lower_message for kw in ["comercial", "plano", "contratar", "assinar", "upgrade", "comprar", "novo plano", "internet melhor"]):
            resultado = {
                "setor": "comercial",
                "resposta": "Que ótimo ter você aqui! Será um prazer ajudar com os planos.\n\nTemos duas ótimas opções principais:\n- SEJA DBS 400MB por R$ 109,90\n- IDEAL DBS 500MB por R$ 119,90\n\nSe você tiver mais de 8 aparelhos em casa, recomendamos nossos planos com tecnologia Wi-Fi 6 para máxima estabilidade!\n\nNos planos com fidelidade de 12 meses, a ativação é totalmente grátis! (Sem fidelidade, taxa de R$ 600,00)\n\nVou transferir você agora mesmo para um de nossos consultores comerciais para escolhermos o melhor pacote!",
                "acao": "transferir_humano",
                "sugestoes": ["Menu Principal", "Estou sem internet", "2ª via do boleto"],
                "contexto": ""
            }
        elif "desbloqueio" in lower_message:
            resultado = {
                "setor": "financeiro",
                "resposta": "Sinal de internet liberado temporariamente por 72 horas.",
                "acao": "desbloqueio_confianca",
                "sugestoes": ["Menu Principal", "Falar com Suporte", "Ver planos"],
                "contexto": ""
            }
        elif "consumo" in lower_message:
            resultado = {
                "setor": "suporte",
                "resposta": "Neste ciclo, você consumiu aproximadamente 215GB da sua franquia de internet.",
                "acao": "consultar_consumo",
                "sugestoes": ["Menu Principal", "Financeiro", "Comercial"],
                "contexto": ""
            }
        elif "contrato" in lower_message:
            resultado = {
                "setor": "comercial",
                "resposta": "Aqui está o link seguro para download do seu contrato: https://demo.ixcsoft.com.br/contrato/123",
                "acao": "enviar_contrato",
                "sugestoes": ["Menu Principal", "Estou sem internet", "2ª via do boleto"],
                "contexto": ""
            }
        else:
            resultado = {
                "setor": "nenhum",
                "resposta": "Olá! Como posso ajudar? Digite 'suporte', 'financeiro' ou 'comercial'.",
                "acao": "nenhuma",
                "sugestoes": ["Ver planos", "2ª via do boleto", "Estou sem internet"],
                "contexto": ""
            }
            
        logger.info(f"Intenção classificada: {resultado['acao']} (Setor: {resultado['setor']}) para a mensagem '{message}' com contexto '{contexto}'")
        return resultado
