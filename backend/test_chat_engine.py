import pytest
from app.services.chat_engine import ChatEngine

def test_classificacao_comercial():
    resultado = ChatEngine.classificar_intencao("quero assinar um plano")
    assert resultado["setor"] == "comercial"
    assert resultado["acao"] == "transferir_humano"

def test_classificacao_financeiro():
    resultado = ChatEngine.classificar_intencao("preciso da 2ª via do boleto")
    assert resultado["setor"] == "financeiro"
    assert resultado["acao"] == "buscar_boleto"

def test_classificacao_suporte_triagem():
    resultado = ChatEngine.classificar_intencao("minha internet está lenta")
    assert resultado["setor"] == "suporte"
    assert resultado["acao"] == "aguardando_teste"

def test_classificacao_suporte_persistencia():
    resultado = ChatEngine.classificar_intencao("o problema continua após reiniciar")
    assert resultado["setor"] == "suporte"
    assert resultado["acao"] == "transferir_humano"
