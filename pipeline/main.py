import argparse
import logging
from pathlib import Path
import sys

if __package__ is None or __package__ == "":
    sys.path.append(str(Path(__file__).resolve().parent.parent))

from pipeline.config import resolve_project_path, settings
from pipeline.db import get_engine
from pipeline.extract import extract_all
from pipeline.transform import transform_all
from pipeline.load import load_all

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("superstore_etl")


def run(source_file: str) -> None:
    logger.info("Starting Superstore ETL pipeline")
    try:
        raw = extract_all(resolve_project_path(source_file))
        clean = transform_all(raw)
        engine = get_engine()
        load_all(engine, clean)
        logger.info("Pipeline completed successfully")
    except Exception:
        logger.exception("Pipeline failed")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Superstore ETL: Excel -> PostgreSQL")
    parser.add_argument(
        "--source",
        default=settings.source_file,
        help="Path to superstore_expanded.xlsx",
    )
    args = parser.parse_args()
    run(args.source)
