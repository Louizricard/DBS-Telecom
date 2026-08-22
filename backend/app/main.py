from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from app.services.ixc_service import IXCService
from app.services.chat_engine import ChatEngine
from datetime import datetime
import logging
import requests
import os
import base64
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="DBS Telecom Backend - MVP")
ixc_service = IXCService()

class LoginRequest(BaseModel):
    cpf: str

class IdentificacaoRequest(BaseModel):
    documento: str

class ChatRequest(BaseModel):
    cliente_id: str
    mensagem: str
    contexto: str = ""

@app.post("/login")
def login(req: LoginRequest):
    ixc_url = os.getenv("IXC_API_URL")
    ixc_token = os.getenv("IXC_API_TOKEN")
    
    if not ixc_url or not ixc_token:
        raise HTTPException(status_code=500, detail="Configurações da API não encontradas")

    token_b64 = base64.b64encode(ixc_token.encode('utf-8')).decode('utf-8')
    headers = {
        'ixcsoft': 'listar',
        'Authorization': f'Basic {token_b64}',
        'Content-Type': 'application/json'
    }

    payload = {
        "qtype": "cnpj_cpf",
        "query": f"%{req.cpf}%",
        "oper": "L",
        "page": "1",
        "rp": "1",
        "sortname": "id",
        "sortorder": "desc"
    }

    try:
        response = requests.post(f"{ixc_url}/cliente", json=payload, headers=headers, timeout=30)
        
        if response.status_code == 200:
            dados = response.json()
            registros = dados.get("registros", [])
            
            if registros:
                cliente = registros[0]
                cliente_id = cliente.get("id")
                plano = ixc_service.buscar_contrato(cliente_id)
                fatura = ixc_service.buscar_fatura_ixc(req.cpf)
                
                fatura_vencimento = None
                fatura_valor = None
                fatura_link = None
                
                if fatura:
                    try:
                        dt = datetime.strptime(fatura['vencimento'], '%Y-%m-%d')
                        fatura_vencimento = dt.strftime('%d/%m/%Y')
                        fatura_valor = f"R$ {float(fatura['valor']):,.2f}".replace(',', 'X').replace('.', ',').replace('X', '.')
                        fatura_link = fatura['link_boleto']
                    except Exception:
                        pass
                
                return {
                    "sucesso": True,
                    "clienteCpf": req.cpf,
                    "clienteNome": cliente.get("razao", "Cliente"),
                    "clientePlano": plano,
                    "faturaValor": fatura_valor,
                    "faturaData": fatura_vencimento,
                    "faturaLink": fatura_link
                }
                
        raise HTTPException(status_code=404, detail="Cliente não encontrado")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro no login: {e}")
        raise HTTPException(status_code=500, detail="Erro interno no servidor")

@app.post("/api/identificar")
def identificar_cliente(req: IdentificacaoRequest):
    cliente = ixc_service.buscar_cliente_por_documento(req.documento)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente não localizado na base.")
        
    logger.info(f"Cliente identificado com sucesso: {cliente['id']} - {cliente['nome']}")
    return {
        "status": "sucesso",
        "cliente_id": cliente["id"],
        "nome": cliente["nome"],
        "saudacao": f"Olá, {cliente['nome']}! 👋 Sou o assistente virtual da DBS TELECOM. Como posso ajudar você hoje?"
    }

@app.post("/api/chat")
def processar_mensagem(req: ChatRequest):
    resultado = ChatEngine.classificar_intencao(req.mensagem, req.contexto, req.cliente_id)
    
    return {
        "setor": resultado["setor"],
        "resposta": resultado["resposta"],
        "acao": resultado["acao"],
        "sugestoes": resultado.get("sugestoes", []),
        "contexto": resultado.get("contexto", "")
    }

@app.get("/faturas/{cpf}")
def obter_faturas(cpf: str):
    faturas = ixc_service.buscar_historico_faturas(cpf)
    return faturas

@app.get("/contratos/{cpf}")
def obter_contratos(cpf: str):
    contratos = ixc_service.buscar_historico_contratos(cpf)
    return contratos
