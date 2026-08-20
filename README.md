# DBS Telecom - MVP Assistente Virtual

Este repositório contém o Produto Mínimo Viável (MVP) do assistente virtual da DBS Telecom, projetado para triagem de atendimento e consulta de dados integrados de forma segura ao sistema IXC Soft.

## Arquitetura

O projeto foi construído utilizando uma separação estrita entre cliente e servidor:

- **Mobile (Frontend):** Desenvolvido em Flutter. É responsável unicamente por apresentar a interface do usuário (UI) fluida e amigável. Não armazena nenhuma regra de negócio crítica ou credencial de terceiros. Toda comunicação de dados é feita requisitando a nossa própria API.
- **Backend (API):** Desenvolvido em Python usando FastAPI. Atua como o cérebro da operação: recebe as requisições do app móvel, processa as intenções do usuário no chat (Suporte, Financeiro, Comercial) e faz as consultas reais ao sistema IXC Soft de maneira segura e abstraída.

## Configuração do Backend

Para rodar a API localmente, siga os passos abaixo:

1. Acesse a pasta do backend:
   ```bash
   cd backend
   ```
2. Crie um ambiente virtual (venv) para isolar as dependências do Python:
   ```bash
   python3 -m venv venv
   ```
3. Ative o ambiente virtual recém-criado:
   - **Linux/macOS:**
     ```bash
     source venv/bin/activate
     ```
   - **Windows:**
     ```cmd
     venv\Scripts\activate
     ```
4. Instale as dependências requeridas do projeto:
   ```bash
   pip install -r requirements.txt
   ```
5. Crie um arquivo chamado `.env` na raiz da pasta `backend/` e adicione as suas credenciais da IXC:
   ```env
   IXC_URL="https://demo.ixcsoft.com.br/webservice/v1"
   IXC_TOKEN="adicione_seu_token_aqui"
   ```
   *(Nota: O arquivo `.env` já está ignorado no `.gitignore` para garantir a segurança do seu token).*

## Execução do Backend

Com o ambiente virtual ativado e dentro da pasta `backend/`, inicie o servidor:

```bash
uvicorn app.main:app --reload
```

A API estará rodando localmente (geralmente em `http://127.0.0.1:8000`).

## Execução do Mobile

Com a API rodando, abra um novo terminal para rodar o aplicativo. Certifique-se de que há um emulador Android/iOS aberto ou um dispositivo físico conectado.

1. Acesse a pasta do projeto Flutter:
   ```bash
   cd mobile/mobile
   ```
2. Execute o aplicativo:
   ```bash
   flutter run
   ```
