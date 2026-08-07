import logging
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine

from pipeline.config import settings

logger = logging.getLogger(__name__)


def get_engine() -> Engine:
    engine = create_engine(settings.sqlalchemy_uri, pool_pre_ping=True)
    logger.info("Created engine for %s@%s:%s/%s",
                settings.db_user, settings.db_host, settings.db_port, settings.db_name)
    return engine