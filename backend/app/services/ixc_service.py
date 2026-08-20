import requests
from app.config import settings

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
        except Exception:
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
        except Exception:
            return None