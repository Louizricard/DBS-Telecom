# DBS Telecom — MVP Assistente Virtual

Monorepo com dois projetos: um backend BFF em FastAPI que fala com a API da IXCSoft (ERP) e um app Flutter que consome só esse backend. Nenhum token da IXC pode aparecer no app.

## Estrutura
- `backend/` — Python 3.12, FastAPI. Rotas em `app/main.py` (`/login`, `/api/identificar`, `/api/chat`, `/faturas/{cpf}`, `/contratos/{cpf}`), chatbot em `app/services/chat_engine.py`, cliente da IXC em `app/services/ixc_service.py`.
- `mobile/mobile/` — app Flutter (telas em `lib/presentation/screens/`, cliente HTTP em `lib/data/services/api_service.dart`).
- O backend de produção roda no Render (`https://dbs-telecom.onrender.com`, hardcoded em `api_service.dart`). Mudança no backend só chega ao app depois do deploy.

## Comandos
Backend (rodar em `backend/`):
```bash
python3 -m venv venv && ./venv/bin/pip install -r requirements.txt pytest   # primeira vez
cp .env.example .env                                                        # e preencher IXC_API_TOKEN
./venv/bin/uvicorn app.main:app --reload                                    # servidor local, porta 8000
IXC_API_URL=http://x IXC_API_TOKEN=x ./venv/bin/pytest -q                   # testes
docker compose up --build                                                   # alternativa via Docker
```

App (rodar em `mobile/mobile/`):
```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release   # exige Android SDK + Java (não instalados nesta máquina)
```

## Variáveis de ambiente
`backend/.env` (ignorado pelo git; modelo em `backend/.env.example`): `IXC_API_URL` e `IXC_API_TOKEN`. Não use `IXC_URL`/`IXC_TOKEN`: o código não lê esses nomes. Sem o `.env` o backend sobe, mas `/login` retorna 500 e as buscas na IXC falham.

## Convenções e armadilhas
- Textos, mensagens e nomes de domínio (`cliente`, `fatura`, `contrato`, `setor`) em português; código e mensagens de commit seguem o estilo já usado no repo.
- `ChatEngine` é uma cascata de `if/elif` por palavras-chave, e a ordem importa: suporte vem antes de financeiro e comercial. Ao mexer nela, rode os testes.
- `ChatEngine` e `main.py` instanciam `IXCService` na importação, então `IXC_API_URL`/`IXC_API_TOKEN` precisam existir (mesmo falsos) para importar o módulo, inclusive nos testes.
- Documentos CPF/CNPJ são salvos com máscara na IXC; `buscar_cliente_por_documento` já formata antes de consultar.
- Não versione `__pycache__`, `.env`, `venv` nem APKs (o APK fica na aba Releases do GitHub).
