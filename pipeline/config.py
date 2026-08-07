import os
from dataclasses import dataclass
from pathlib import Path
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent

load_dotenv(PROJECT_ROOT / ".env")


def resolve_project_path(path_value: str | None) -> str | None:
    if not path_value:
        return None

    path = Path(path_value.strip()).expanduser()
    if path.is_absolute():
        return str(path)
    return str(PROJECT_ROOT / path)

@dataclass
class Settings:
    db_host: str = os.getenv("DB_HOST")
    db_port: str = os.getenv("DB_PORT")
    db_name: str = os.getenv("DB_NAME")
    db_user: str = os.getenv("DB_USER")
    db_password: str = os.getenv("DB_PASSWORD")
    source_file: str = resolve_project_path(os.getenv("SOURCE_FILE"))

    @property
    def sqlalchemy_uri(self) -> str:
        return (
            f"postgresql+psycopg2://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )

settings = Settings()
