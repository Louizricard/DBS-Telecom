import os
from dotenv import load_dotenv

# Carrega as variáveis de ambiente do arquivo .env
load_dotenv()

class Settings:
    IXC_API_URL: str = os.getenv("IXC_API_URL", "")
    IXC_API_TOKEN: str = os.getenv("IXC_API_TOKEN", "")

settings = Settings()
