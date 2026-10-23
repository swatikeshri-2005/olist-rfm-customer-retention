-- Customer-level RFM analysis for DuckDB.
-- Assumes these tables are registered in DuckDB:
--   orders(order_id, customer_id, order_status, order_purchase_timestamp)
--   customers(customer_id, customer_unique_id)
--   order_items(order_id, price)
--
-- Monetary value uses item price only (freight excluded).
-- Only delivered orders are included.

CREATE OR REPLACE TEMP VIEW delivered_order_value AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    CAST(o.order_purchase_timestamp AS TIMESTAMP) AS purchase_ts,
    SUM(COALESCE(oi.price, 0)) AS order_monetary_value
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
JOIN order_items AS oi
  ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    CAST(o.order_purchase_timestamp AS TIMESTAMP);

CREATE OR REPLACE TEMP VIEW rfm_base AS
WITH reference AS (
    SELECT CAST(MAX(purchase_ts) + INTERVAL 1 DAY AS TIMESTAMP) AS reference_date
    FROM delivered_order_value
)
SELECT
    d.customer_unique_id,
    DATE_DIFF('day', MAX(d.purchase_ts), r.reference_date) AS recency_days,
    COUNT(DISTINCT d.order_id) AS frequency,
    SUM(d.order_monetary_value) AS monetary,
    MAX(d.purchase_ts) AS last_purchase_ts,
    MIN(d.purchase_ts) AS first_purchase_ts
FROM delivered_order_value AS d
CROSS JOIN reference AS r
GROUP BY d.customer_unique_id, r.reference_date;

-- Quantile-based scores. Recency is reversed: fewer days = higher score.
CREATE OR REPLACE TEMP VIEW rfm_scored AS
WITH scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    *,
    CAST(r_score AS VARCHAR) || CAST(f_score AS VARCHAR) || CAST(m_score AS VARCHAR) AS rfm_score,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 4 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3 THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'Needs Attention'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'At Risk'
        ELSE 'Potential Loyalists'
    END AS customer_segment
FROM scored;

SELECT * FROM rfm_scored ORDER BY monetary DESC;
