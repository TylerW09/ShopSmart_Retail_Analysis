import logging

import pandas as pd
from sqlalchemy.engine import Engine

logger = logging.getLogger(__name__)


def load_table(engine: Engine, table_name: str, df: pd.DataFrame) -> None:
    logger.info("Loading %s rows into %s", len(df), table_name)
    df.to_sql(table_name, engine, if_exists="replace", index=False)


def load_all(engine: Engine, clean: dict[str, pd.DataFrame]) -> None:
    load_table(engine, "orders", clean["orders"])
    load_table(engine, "people", clean["people"])
    load_table(engine, "returns", clean["returns"])
