-- Business Question 1: Which product categories generate the  highest revenue and profit?
Select * from orders
LIMIT 10;

WITH category_summary AS (
    SELECT
        category,
        ROUND(SUM(sales)::numeric, 2)       AS total_revenue,
        ROUND(SUM(profit)::numeric, 2)      AS total_profit,
        SUM(quantity)                       AS units_sold,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 0) AS profit_margin_pct
    FROM orders
    GROUP BY category
)
SELECT
    category,
    total_revenue,
    total_profit,
    units_sold,
    profit_margin_pct,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_profit DESC)  AS profit_rank
FROM category_summary
ORDER BY total_revenue DESC;

-- Business Question 2: Which products are losing us money?

WITH product_summary AS (
    SELECT
        product_id,
        product_name,
        category,
        ROUND(SUM(sales)::numeric, 2)    AS total_revenue,
        ROUND(SUM(profit)::numeric, 2)   AS total_profit,
        SUM(quantity)                    AS units_sold,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 0) AS profit_margin_pct
    FROM orders
    GROUP BY product_id, product_name, category
)
SELECT *
FROM product_summary
WHERE total_profit < 0
ORDER BY total_profit ASC;

-- Part B: High sales but low profit 
-- products that look good on a revenue report but aren't earning their keep).
-- Uses NTILE to bucket products into revenue quartiles, then filters
-- for top-quartile revenue with bottom-quartile margin.
 
WITH product_summary AS (
    SELECT
        product_id,
        product_name,
        category,
        ROUND(SUM(sales)::numeric, 2)  AS total_revenue,
        ROUND(SUM(profit)::numeric, 2) AS total_profit,
        ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 0) AS profit_margin_pct
    FROM orders
    GROUP BY product_id, product_name, category
),
ranked AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY total_revenue DESC)        AS revenue_quartile,
        NTILE(4) OVER (ORDER BY profit_margin_pct ASC)     AS margin_quartile
    FROM product_summary
)
SELECT product_id, product_name, category, total_revenue, total_profit, profit_margin_pct
FROM ranked
WHERE revenue_quartile = 1   -- top 25% by revenue
  AND margin_quartile = 1    -- bottom 25% by margin
ORDER BY total_revenue DESC;
 
 

-- Business Question 3: Which states or regions perform best?

WITH state_summary AS (
    SELECT
        region,
        state_province,
        ROUND(SUM(sales)::numeric, 2)   AS total_revenue,
        ROUND(SUM(profit)::numeric, 2)  AS total_profit,
        COUNT(DISTINCT order_id)        AS total_orders,
        ROUND((SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0))::numeric, 0) AS avg_order_value
    FROM orders
    GROUP BY region, state_province
)
SELECT
    region,
    state_province,
    total_revenue,
    total_profit,
    total_orders,
    avg_order_value,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM state_summary
ORDER BY total_revenue DESC
LIMIT 10;
 
-- Regional roll-up 
SELECT
    region,
    ROUND(SUM(sales)::numeric, 2)   AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)  AS total_profit,
    COUNT(DISTINCT order_id)        AS total_orders,
    ROUND((SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0))::numeric, 0) AS avg_order_value
FROM orders
GROUP BY region
ORDER BY total_revenue DESC;


-- Business Question 4: Who are our most valuable customers?
-- NTILE buckets customers into value tiers for easy segmentation.
 
WITH customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(DISTINCT order_id)                     AS purchase_frequency,
        ROUND(SUM(sales)::numeric, 2)                AS total_spend,
        ROUND(SUM(profit)::numeric, 2)                AS lifetime_profit_contribution,
        ROUND((SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0))::numeric, 0) AS avg_order_value
    FROM orders
    GROUP BY customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    purchase_frequency,
    total_spend,
    lifetime_profit_contribution,
    avg_order_value,
    NTILE(4) OVER (ORDER BY total_spend DESC) AS value_tier   -- 1 = top 25% by spend
FROM customer_summary
ORDER BY total_spend DESC;
 
 

-- Business Question 5: How effective are our discounts?
-- Average discount, revenue vs discount, profit vs discount,
-- broken out overall and by category.
 
-- Overall discount bands (bucket discount into ranges, see impact on profit)
WITH discount_bands AS (
    SELECT
        CASE
            WHEN discount = 0 THEN '0% (no discount)'
            WHEN discount <= 0.10 THEN '1-10%'
            WHEN discount <= 0.20 THEN '11-20%'
            WHEN discount <= 0.30 THEN '21-30%'
            WHEN discount <= 0.50 THEN '31-50%'
            ELSE '50%+'
        END AS discount_band,
        sales,
        profit
    FROM orders
)
SELECT
    discount_band,
    COUNT(*)  AS order_lines,
    ROUND(SUM(sales)::numeric, 2)  AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct
FROM discount_bands
GROUP BY discount_band
ORDER BY MIN(
    CASE discount_band
        WHEN '0% (no discount)' THEN 0
        WHEN '1-10%' THEN 1
        WHEN '11-20%' THEN 2
        WHEN '21-30%' THEN 3
        WHEN '31-50%' THEN 4
        ELSE 5
    END
);
 
-- Discount effectiveness by category
SELECT
    category,
    ROUND((AVG(discount) * 100)::numeric, 2)   AS avg_discount_pct,
    ROUND(SUM(sales)::numeric, 2)              AS total_revenue,
    ROUND(SUM(profit)::numeric, 2)             AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 0) AS profit_margin_pct
FROM orders
GROUP BY category
ORDER BY avg_discount_pct DESC;
 
 
-- Business Question 6: Are customers returning?
-- Repeat purchase rate, new vs returning, avg days between purchases.
 
-- Repeat purchase rate: % of customers with more than 1 order
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT order_id) AS num_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) FILTER (WHERE num_orders > 1)                      AS repeat_customers,
    COUNT(*)                                                    AS total_customers,
    ROUND(
        COUNT(*) FILTER (WHERE num_orders > 1)::numeric
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                            AS repeat_purchase_rate_pct
FROM customer_orders;
 
-- New vs returning customers, by month (based on each customer's first order date)
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),
monthly_orders AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', o.order_date) AS order_month,
        f.first_order_date,
        CASE
            WHEN DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', f.first_order_date)
            THEN 'New'
            ELSE 'Returning'
        END AS customer_type
    FROM orders o
    JOIN first_orders f ON o.customer_id = f.customer_id
)
SELECT
    order_month,
    customer_type,
    COUNT(DISTINCT customer_id) AS num_customers
FROM monthly_orders
GROUP BY order_month, customer_type
ORDER BY order_month, customer_type;
 
-- Average days between purchases per customer (uses LAG window function)
WITH order_gaps AS (
    SELECT
        customer_id,
        customer_name,
        order_date,
        order_date - LAG(order_date) OVER (
            PARTITION BY customer_id ORDER BY order_date
        ) AS days_since_last_order
    FROM orders
)
SELECT
    customer_id,
    customer_name,
    AVG(days_since_last_order) AS avg_days_between_purchases
FROM order_gaps
WHERE days_since_last_order IS NOT NULL
GROUP BY customer_id,customer_name
ORDER BY avg_days_between_purchases ASC;
 
 
-- Business Question 7: How are shipping choices affecting
-- customer satisfaction?
-- Shipping mode, delivery time, and return rate.
-- return rate is used as the closest proxy for customer satisfaction.
 
WITH shipping_summary AS (
    SELECT
        o.ship_mode,
        (AVG(o.ship_date - o.order_date)) AS avg_delivery_days,
        COUNT(DISTINCT o.order_id)                AS total_orders,
        COUNT(DISTINCT r.order_id)                AS returned_orders
    FROM orders o
    LEFT JOIN returns r
        ON o.order_id = r.order_id AND r.returned = 'Yes'
    GROUP BY o.ship_mode
)
SELECT
    ship_mode,
    avg_delivery_days,
    total_orders,
    returned_orders,
    ROUND(returned_orders::numeric / NULLIF(total_orders, 0) * 100) AS return_rate_pct
FROM shipping_summary
ORDER BY avg_delivery_days DESC;