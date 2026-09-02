# ShopSmart Retail: Executive Business Analysis

## Table of Contents
- [Executive Summary](#executive-summary)
- [Business Problem](#business-problem)
- [Data Source](#data-source)
- [Methodology](#methodology)
- [Tech Stack](#tech-stack)
- [Skills Demonstrated](#skills-demonstrated)
- [Results & Business Recommendations](#results--business-recommendations)
- [Dashboard](#dashboard)
---

## Executive Summary

ShopSmart Retail, a mid-sized U.S. e-commerce retailer, saw revenue grow only 2% quarter-over-quarter despite an 18% increase in marketing spend, alongside shrinking profit margins and declining customer satisfaction. This project investigates the root causes using SQL, Python, and Tableau, and delivers concrete, data-backed recommendations for the executive team.

**Key finding:** The core issue isn't a demand problem — it's a margin problem. The **Furniture category generates $7.4M in revenue but runs a -5.5% profit margin overall**, actively dragging down company-wide profitability even as top-line revenue holds steady. Meanwhile, the retailer's top customer segment ("Champions") spends **~2.3x more** than its lowest-value segment, pointing to retention as a higher-leverage lever than acquisition spend.

---

## Business Problem

Leadership raised the investigation after last quarter's results showed:

| Department | Concern |
|---|---|
| Marketing | Spend is up, but sales aren't scaling with it |
| Finance | Profit margins are shrinking |
| Operations | Some products sell out while others never move |
| Customer Success | Customer satisfaction has declined |

The CEO's mandate was direct: *"I don't want another dashboard with pretty charts. I want to know: What's happening? Why is it happening? What should we do?"*

This project answers that mandate across eight business questions: category/product profitability, regional performance, customer value, discount effectiveness, retention, shipping/returns impact on satisfaction, and a forward sales forecast.

---

## Data Source

- **Dataset:** Sample Superstore retail analytics dataset containing Orders, People (regional managers), and Returns
- **Scope:** 75,194 order line items, January 2023 – December 2026
- **Note:** This is a synthetic/practice dataset, not real ShopSmart Retail transaction data — the company and business scenario are a simulation used to structure this project as a realistic executive analytics engagement

---

## Methodology

1. **ETL Pipeline** — Extracted raw data from the source Excel workbook (Orders, People, Returns sheets) and loaded it into a PostgreSQL database for structured querying.
2. **SQL Analysis** — Wrote queries using CTEs, window functions (`RANK`, `NTILE`, `LAG`), and aggregate functions to answer core business questions directly against the database: category/product profitability, regional performance, customer value, discount bands, retention, and shipping/return rates.
3. **Python Analysis** — Connected to PostgreSQL via `sqlalchemy`, then performed data validation, exploratory data analysis, correlation analysis (discount vs. profit), and RFM (Recency, Frequency, Monetary) customer segmentation using `pandas`, `numpy`, `matplotlib`, and `scikit-learn`.
4. **Sales Forecasting** — Built a trend + seasonality regression model (`scikit-learn LinearRegression` with month-of-year dummy variables) to forecast the next 3 months of revenue, validated via a backtest against the most recent 3 known months (2.7% MAPE).
5. **Dashboard** — Built an interactive executive dashboard in Tableau Public summarizing KPIs, category/regional performance, customer segments, and the sales forecast.

---

## Tech Stack

| Area | Tools |
|---|---|
| Database | PostgreSQL |
| Programming | Python (pandas, numpy, matplotlib, scikit-learn) |
| Notebook | Jupyter Notebook |
| SQL | CTEs, window functions, aggregate/ranking functions |
| Visualization / BI | Tableau Public |
| Version Control | Git & GitHub |

---

## Skills Demonstrated

- SQL: joins, CTEs, window functions (`RANK`, `NTILE`, `LAG`), aggregate functions
- Python: data cleaning/validation, exploratory data analysis, correlation analysis
- Statistics/ML: RFM customer segmentation, regression-based time series forecasting, model backtesting
- Data visualization: executive dashboard design (Tableau Public)
- Business communication: translating analytical findings into actionable, executive-level recommendations

---

## Results & Business Recommendations

### 1. Category Profitability
Technology is the strongest performer ($17.4M revenue, 14.7% margin). **Furniture is the clear problem area**: $7.4M in revenue but a **-5.5% overall profit margin** — it's actively losing money despite solid sales volume.

**Recommendation:** Reassess Furniture pricing and/or supplier costs. Investigate whether shipping costs (bulky items) or base markup is the primary driver before defaulting to discount cuts alone.

### 2. Discount Impact
Correlation between discount level and profit is weaker company-wide than expected, but Furniture shows the strongest negative relationship of the three categories — suggesting its margin problem is more structural (thin base margin, shipping cost) than purely discount-driven.

**Recommendation:** Don't treat discounting as the single lever — validate cost structure for Furniture SKUs specifically before adjusting company-wide discount policy.

### 3. Customer Value (RFM Segmentation)
804 customers segmented into 5 tiers. "Champions" average **$48.8K** in lifetime spend vs. **$21.2K** for the lowest-value "Needs Attention" segment — roughly a 2.3x gap.

**Recommendation:** Shift a portion of acquisition marketing budget toward retention programs targeting "Loyal Customers" and "Potential Loyalists" — moving customers up a tier is likely more cost-effective than acquiring new ones at current CAC.

### 4. Sales Forecast
Model backtested at **2.7% MAPE** against the most recent 3 known months. Forward forecast shows relatively flat revenue with mild seasonality — no strong growth or decline signal.

**Recommendation:** Since the forecast shows flat revenue, the 2% growth issue is not a demand problem — it's a margin problem. Budget and inventory planning should prioritize fixing category-level profitability over chasing top-line growth.

### 5. Regional Performance
Central ($8.6M revenue) and West ($8.5M revenue) are the top two regions, but **West is notably more profitable** ($760K profit) than Central ($679K profit) despite near-identical revenue — a margin efficiency gap, not a volume gap. South has the lowest total profit of all four regions ($507K) even though its revenue outpaces East. California is the single highest-performing state by a wide margin ($4.08M revenue, $334K profit).

**Recommendation:** Marketing budget reallocation should weight West more heavily relative to its revenue share — it's converting revenue to profit more efficiently than Central. South's profit underperformance is worth a follow-up category-mix analysis (it may be a Furniture concentration issue).

### 6. Discount Effectiveness
Discount bands reveal a clear breaking point: orders with **0% and 11-20% discount hold healthy ~13% margins**, but **21-30% discount tips to a -4.5% margin**, and **50%+ discount collapses to -13.4% margin**. The 31-50% band essentially breaks even (0.07% margin) — meaning almost every dollar of deep discounting past ~20% is destroying profit rather than driving profitable volume. This lines up directly with the Furniture finding: **Furniture carries the highest average discount of the three categories (21.8%)**, right at the tipping point where margin turns negative.

**Recommendation:** Cap standard discounting at 20% company-wide as a default policy, with exceptions requiring explicit approval. This single change would directly address both the Finance and Furniture-margin concerns.

### 7. Shipping & Returns
Return rate overall is **6.53%** (2,446 of 37,459 orders). Contrary to Operations' hypothesis that shipping delays drive poor reviews, the data shows the **opposite pattern**: Same Day shipping (fastest, ~0 days) has the *highest* return rate at 7.56%, while Standard Class (slowest, ~5 days) sits at 6.45% — right in line with the average. Return rate does not clearly increase with delivery time in this dataset.

**Recommendation:** Don't assume delivery speed is the satisfaction driver — investigate return reasons (if available) rather than defaulting to a shipping-speed fix. Same Day shipping in particular may warrant its own root-cause look, since it's both the fastest and the least reliable in terms of return outcomes.



---

## Data Quality Notes

- **Ship Mode inconsistency:** the raw data contains multiple inconsistent labels for the same shipping tier (e.g. "First Class" / "First class", "Standard Class" / "Standard  Class" with a double space, "Same Day" / "Same-Day", "2nd Class" / "Second Class"). These were normalized during analysis (case + whitespace + hyphen standardization) to get accurate shipping-mode aggregates. 

- **Dataset timeline:** order dates run from January 2023 through December 2026 — about 11% of rows have order dates later than today's real-world date, since this is a synthetic/extended dataset built for practice, not real historical transactions. The sales forecast treats the dataset's own last order date as "now."

---

## Dashboard


![ShopSmart Retail Executive Dashboard](tableau/ExecutiveDashboard.png)


---




