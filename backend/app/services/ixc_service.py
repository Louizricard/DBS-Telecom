import requests
import logging
from app.config import settings

logger = logging.getLogger(__name__)

class IXCService:
    def __init__(self):
        self.url = settings.IXC_API_URL
        self.token = settings.IXC_API_TOKEN
        import base64
        token_b64 = base64.b64encode(self.token.encode('utf-8')).decode('utf-8')
        self.headers = {
            'ixcsoft': 'listar',
            'Authorization': f'Basic {token_b64}',
            'Content-Type': 'application/json'
        }

    def buscar_cliente_por_documento(self, documento: str) -> dict:
        # A IXC salva o documento com máscara (ex: 773.875.706-04), então 
        # testamos tanto o valor exato digitado quanto uma versão com LIKE se necessário.
        doc_busca = documento.strip()
        endpoint = f"{self.url}/cliente"
        
        payload = {
            "qtype": "cnpj_cpf",
            "query": f"%{doc_busca}%",
            "oper": "L",
            "page": "1",
            "rp": "1",
            "sortname": "id",
            "sortorder": "desc"
        }
        
        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=30)
            
            if response.status_code == 200:
                dados = response.json()
                registros = dados.get("registros", [])
                
                if registros:
                    cliente = registros[0]
                    nome_completo = cliente.get("razao", "Cliente")
                    primeiro_nome = nome_completo.split()[0].capitalize()
                    
                    return {
                        "id": cliente.get("id"),
                        "nome": primeiro_nome,
                        "nome_completo": nome_completo,
                        "documento": doc_busca
                    }
            return None
        except Exception as e:
            logger.error(f"Falha na conexão com a API da IXC ao buscar cliente: {e}")
            return None

    def buscar_boleto(self, cliente_id: str) -> dict:
        endpoint = f"{self.url}/fn_areceber"
        
        payload = {
            "qtype": "fn_areceber.id_cliente",
            "query": cliente_id,
            "oper": "=",
            "page": "1",
            "rp": "1",
            "sortname": "fn_areceber.data_vencimento",
            "sortorder": "desc"
        }
        
        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=10)
            if response.status_code == 200:
                dados = response.json()
                registros = dados.get("registros", [])
                
                if registros:
                    boleto = registros[0]
                    return {
                        "id_boleto": boleto.get("id"),
                        "valor": boleto.get("valor"),
                        "vencimento": boleto.get("data_vencimento"),
                        "link": f"https://demo.ixcsoft.com.br/central_assinante_web/boleto/{boleto.get('id')}"
                    }
            return None
        except Exception as e:
            logger.error(f"Falha na conexão com a API da IXC ao buscar boleto: {e}")
            return None

    def buscar_contrato(self, cliente_id: str) -> str:
        endpoint = f"{self.url}/cliente_contrato"
        
        payload = {
            "qtype": "cliente_contrato.id_cliente",
            "query": cliente_id,
            "oper": "=",
            "page": "1",
            "rp": "1",
            "sortname": "id",
            "sortorder": "desc"
        }
        
        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=10)
            if response.status_code == 200:
                dados = response.json()
                registros = dados.get("registros", [])
                
                if registros:
                    contrato = registros[0]
                    # IXC can return the plan in 'plano' or 'contrato' fields, depending on the view.
                    plano_nome = contrato.get("plano") or contrato.get("contrato")
                    if plano_nome:
                        return str(plano_nome)
            return "DBS Fibra"
        except Exception as e:
            logger.error(f"Falha na conexão com a API da IXC ao buscar contrato: {e}")
            return "DBS Fibra"

    def buscar_fatura_ixc(self, cpf: str) -> dict:
        cliente = self.buscar_cliente_por_documento(cpf)
        if not cliente:
            return None
        
        boleto = self.buscar_boleto(cliente["id"])
        if not boleto:
            return None
            
        return {
            "valor": boleto.get("valor"),
            "vencimento": boleto.get("vencimento"),
            "link_boleto": boleto.get("link")
        }

    def buscar_historico_faturas(self, cpf: str) -> list:
        cliente = self.buscar_cliente_por_documento(cpf)
        if not cliente:
            return []
            
        endpoint = f"{self.url}/fn_areceber"
        payload = {
            "qtype": "fn_areceber.id_cliente",
            "query": cliente["id"],
            "oper": "=",
            "page": "1",
            "rp": "50",
            "sortname": "fn_areceber.data_vencimento",
            "sortorder": "desc"
        }
        
        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=15)
            if response.status_code == 200:
                dados = response.json()
                registros = dados.get("registros", [])
                
                faturas = []
                import datetime
                hoje = datetime.date.today()
                
                for r in registros:
                    status_raw = str(r.get("status", "")).upper()
                    
                    if status_raw == "R" or r.get("data_pagamento") or status_raw == "PAGO":
                        status = "pago"
                    else:
                        venc_str = r.get("data_vencimento")
                        if venc_str:
                            try:
                                dt_venc = datetime.datetime.strptime(venc_str, '%Y-%m-%d').date()
                                if dt_venc < hoje:
                                    status = "atrasado"
                                else:
                                    status = "pendente"
                            except Exception:
                                status = "pendente"
                        else:
                            status = "pendente"
                            
                    faturas.append({
                        "id": r.get("id"),
                        "valor": r.get("valor"),
                        "vencimento": r.get("data_vencimento"),
                        "status": status,
                        "link_boleto": f"https://demo.ixcsoft.com.br/central_assinante_web/boleto/{r.get('id')}"
                    })
                return faturas
            return []
        except Exception:
            return []

    def buscar_historico_contratos(self, cpf: str) -> list:
        cliente = self.buscar_cliente_por_documento(cpf)
        if not cliente:
            return []
            
        endpoint = f"{self.url}/cliente_contrato"
        payload = {
            "qtype": "cliente_contrato.id_cliente",
            "query": cliente["id"],
            "oper": "=",
            "page": "1",
            "rp": "50",
            "sortname": "id",
            "sortorder": "desc"
        }
        
        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=15)
            if response.status_code == 200:
                dados = response.json()
                registros = dados.get("registros", [])
                
                contratos = []
                for r in registros:
                    status_raw = str(r.get("status", "")).upper()
                    if status_raw in ["A", "ATIVO"]:
                        status = "ativo"
                    elif status_raw in ["B", "BLOQUEADO"]:
                        status = "bloqueado"
                    elif status_raw in ["C", "CANCELADO"]:
                        status = "cancelado"
                    else:
                        status = status_raw.lower() if status_raw else "desconhecido"
                        
                    plano = r.get("plano") or r.get("contrato") or "DBS Fibra"
                    
                    data_ativacao = r.get("data_ativacao") or r.get("data_assinatura") or "N/A"
                    if data_ativacao != "N/A" and "-" in data_ativacao:
                        try:
                            partes = data_ativacao.split("-")
                            if len(partes) == 3:
                                data_ativacao = f"{partes[2]}/{partes[1]}/{partes[0]}"
                        except Exception:
                            pass
                            
                    contratos.append({
                        "id": r.get("id"),
                        "plano": str(plano),
                        "status": status,
                        "data_ativacao": data_ativacao
                    })
                return contratos
            return []
        except Exception:
            return []