# DBS Telecom - MVP Assistente Virtual

Este repositório contém o projeto que desenvolvi para o desafio técnico da DBS Telecom. O objetivo foi criar um Produto Mínimo Viável (MVP) de um portal de autoatendimento para assinantes de provedores de internet. Todo o desenvolvimento foi concluído em um prazo de 7 dias.

**Nota:** O backend construído para este projeto já encontra-se hospedado e operando em nuvem. Para avaliar o aplicativo, não é estritamente necessário configurar o ambiente local. Basta realizar o download e instalação do aplicativo (APK) em um dispositivo Android.
- **Onde encontrar o APK:** O arquivo de instalação está disponível na aba de **Releases** do GitHub (ou caso prefira, diretamente na pasta `mobile/mobile/build/app/outputs/flutter-apk/app-release.apk` deste repositório).
- **Como instalar:** Transfira o arquivo para o seu smartphone Android, abra-o através do gerenciador de arquivos e autorize a instalação de "fontes desconhecidas" (padrão de segurança do Android para apps externos). Após isso, o app estará pronto para uso conectando-se diretamente ao backend na nuvem.

## Arquitetura e Segurança

Para garantir a segurança dos dados e das integrações, optei por não fazer a comunicação com a API externa diretamente pelo aplicativo. Utilizei o padrão de arquitetura BFF (Backend For Frontend).

- **Frontend:** Desenvolvido em Flutter (Dart). A interface foca na usabilidade do usuário, consumindo apenas os dados que já foram formatados e higienizados pelo backend.
- **Backend:** Desenvolvido em Python utilizando o framework FastAPI. Este backend atua como intermediário, recebendo as requisições do app e comunicando-se de forma segura com a API da IXCSoft (sistema ERP).

O ponto principal dessa decisão arquitetural é a segurança: nenhuma chave de API, token de acesso ou regra de negócio sensível fica exposta no código fonte do aplicativo. Todo o processo de autenticação com a IXCSoft fica estritamente protegido no servidor.

## Funcionalidades

Durante o desenvolvimento do MVP, priorizei as funcionalidades que geram maior valor para o atendimento ao cliente:

- **Login Passwordless:** Acesso simplificado utilizando apenas o CPF/CNPJ do assinante, reduzindo o atrito no uso do aplicativo.
- **Dashboard e Histórico:** Visão geral da conexão atual do cliente, exibição de faturas pendentes e acesso ao histórico completo de contratos.
- **Chatbot Inteligente (Destaque do Projeto):** Criei um motor de Processamento de Linguagem Natural (PNL) básico no backend. O chatbot é capaz de:
  - Identificar a intenção da mensagem do usuário e direcionar para o setor correto (Comercial, Suporte Técnico ou Financeiro).
  - Chamar o cliente pelo nome, tornando a interação mais humana e menos robotizada.
  - Fazer uma triagem inicial do problema relatado.
  - Recuperar dinamicamente a 2ª via do boleto e enviar o link no chat de forma automática, caso identificado no texto do cliente.

## Como executar localmente

Para testar o ambiente localmente, é necessário rodar o backend em Python e em seguida o aplicativo em Flutter.

### Backend
1. Acesse o diretório `backend`
2. Crie e ative um ambiente virtual: 
   - Linux/Mac: `python3 -m venv venv` e `source venv/bin/activate`
   - Windows: `python -m venv venv` e `venv\Scripts\activate`
3. Instale as dependências executando `pip install -r requirements.txt`
4. Crie um arquivo `.env` na raiz do backend contendo as variáveis de ambiente necessárias:
   ```env
   IXC_URL="https://demo.ixcsoft.com.br/webservice/v1"
   IXC_TOKEN="seu_token_aqui"
   ```
5. Inicie o servidor localmente com o comando: `uvicorn app.main:app --reload`

### App Mobile
1. Acesse o diretório `mobile/mobile`
2. Atualize os pacotes do projeto rodando `flutter pub get`
3. Com um emulador aberto ou dispositivo conectado, execute o app com o comando `flutter run`
