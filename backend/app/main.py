from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.services.ixc_service import IXCService
from app.services.chat_engine import ChatEngine

app = FastAPI(title="DBS Telecom Backend - MVP")
ixc_service = IXCService()

class IdentificacaoRequest(BaseModel):
    documento: str

class ChatRequest(BaseModel):
    cliente_id: str
    mensagem: str

@app.post("/api/identificar")
def identificar_cliente(req: IdentificacaoRequest):
    cliente = ixc_service.buscar_cliente_por_documento(req.documento)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente não localizado na base.")
        
    return {
        "status": "sucesso",
        "cliente_id": cliente["id"],
        "nome": cliente["nome"],
        "saudacao": f"Olá, {cliente['nome']}! 👋 Sou o assistente virtual da DBS TELECOM. Como posso ajudar você hoje?"
    }

@app.post("/api/chat")
def processar_mensagem(req: ChatRequest):
    resultado = ChatEngine.classificar_intencao(req.mensagem)
    
    if resultado["acao"] == "buscar_boleto":
        boleto = ixc_service.buscar_boleto(req.cliente_id)
        if boleto:
            resultado["resposta"] = f"Encontrei seu boleto no valor de R$ {boleto['valor']} com vencimento para {boleto['vencimento']}. Você pode acessá-lo aqui: {boleto['link']}"
        else:
            resultado["resposta"] = "Consultei o sistema, mas não encontrei nenhum boleto em aberto para o seu cadastro no momento."
            
    return {
        "setor": resultado["setor"],
        "resposta": resultado["resposta"],
        "acao": resultado["acao"]
    }
