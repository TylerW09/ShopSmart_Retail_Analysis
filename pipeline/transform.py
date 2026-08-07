import logging
import pandas as pd

logger = logging.getLogger(__name__)

SHIP_MODE_MAPPING = {
    "Standard  Class": "Standard Class",
    "2nd Class": "Second Class",
    "First class": "First Class",
    "Same-Day": "Same Day",
}

RENAME_ORDERS = {
    "Order ID": "order_id",
    "Order Date": "order_date",
    "Ship Date": "ship_date",
    "Ship Mode": "ship_mode",
    "Customer ID": "customer_id",
    "Customer Name": "customer_name",
    "Segment": "segment",
    "Country/Region": "country_region",
    "City": "city",
    "State/Province": "state_province",
    "Postal Code": "postal_code",
    "Region": "region",
    "Product ID": "product_id",
    "Category": "category",
    "Sub-Category": "sub_category",
    "Product Name": "product_name",
    "Sales": "sales",
    "Quantity": "quantity",
    "Discount": "discount",
    "Profit": "profit",
}

RENAME_PEOPLE = {"Regional Manager": "regional_manager", "Region": "region"}
RENAME_RETURNS = {"Order ID": "order_id", "Returned": "returned"}


def transform_orders(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    before = df.shape[0]

    if "Row ID" in df.columns:
        df = df.drop(columns=["Row ID"])  # Postgres SERIAL PK replaces this

    df["Postal Code"] = df["Postal Code"].fillna("N/A")

    neg_sales = df[df["Sales"] < 0].shape[0]
    if neg_sales:
        logger.info("Found %s rows with negative Sales", neg_sales)

    neg_qty = df[df["Quantity"] < 0].shape[0]
    if neg_qty:
        logger.info("Dropping %s rows with negative Quantity", neg_qty)
        df = df[df["Quantity"] >= 0]

    dupes = df.duplicated().sum()
    if dupes:
        logger.info("Dropping %s duplicate rows", dupes)
        df = df.drop_duplicates()

    df["Ship Mode"] = df["Ship Mode"].replace(SHIP_MODE_MAPPING)
    df["Customer Name"] = df["Customer Name"].str.strip().str.title()
    df["City"] = df["City"].str.strip().str.title()
    df["State/Province"] = df["State/Province"].str.strip().str.title()

    df = df.rename(columns=RENAME_ORDERS)

    logger.info("Orders transform: %s -> %s rows", before, df.shape[0])
    return df


def transform_people(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df = df.rename(columns=RENAME_PEOPLE)
    df = df.drop_duplicates()
    return df


def transform_returns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    before = df.shape[0]

    dupes = df.duplicated().sum()
    if dupes:
        logger.info("Dropping %s duplicate rows from Returns", dupes)
        df = df.drop_duplicates()

    df["Returned"] = df["Returned"].apply(lambda x: str(x).strip().lower() == "yes")
    df = df.rename(columns=RENAME_RETURNS)

    logger.info("Returns transform: %s -> %s rows", before, df.shape[0])
    return df


def transform_all(raw: dict) -> dict:
    return {
        "orders": transform_orders(raw["orders"]),
        "people": transform_people(raw["people"]),
        "returns": transform_returns(raw["returns"]),
    }
