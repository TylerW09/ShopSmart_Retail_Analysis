import logging
from pathlib import Path
import pandas as pd

logger = logging.getLogger(__name__)


def extract_all(source_path: str) -> dict[str, pd.DataFrame]:
    path = Path(source_path)
    if not path.exists():
        raise FileNotFoundError(f"Source file not found: {source_path}")

    logger.info("Reading workbook: %s", source_path)
    xls = pd.ExcelFile(path)

    required_sheets = {"Orders", "People", "Returns"}
    missing = required_sheets - set(xls.sheet_names)
    if missing:
        raise ValueError(f"Missing expected sheet(s) in workbook: {missing}")

    orders = pd.read_excel(xls, sheet_name="Orders")
    people = pd.read_excel(xls, sheet_name="People")
    returns = pd.read_excel(xls, sheet_name="Returns")

    logger.info(
        "Extracted Orders=%s People=%s Returns=%s",
        orders.shape, people.shape, returns.shape,
    )
    return {"orders": orders, "people": people, "returns": returns}