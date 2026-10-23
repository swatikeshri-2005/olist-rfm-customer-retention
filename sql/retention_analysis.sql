-- Repeat-purchase and monthly cohort retention for DuckDB.
-- Assumes delivered_order_value view exists (see rfm_analysis.sql).
-- A customer is counted once per calendar month in which they placed
-- at least one delivered order.

CREATE OR REPLACE TEMP VIEW customer_months AS
SELECT DISTINCT
    customer_unique_id,
    DATE_TRUNC('month', purchase_ts)::DATE AS order_month
FROM delivered_order_value;

CREATE OR REPLACE TEMP VIEW customer_cohorts AS
SELECT
    customer_unique_id,
    MIN(order_month) AS cohort_month
FROM customer_months
GROUP BY customer_unique_id;

CREATE OR REPLACE TEMP VIEW cohort_activity AS
SELECT
    cm.customer_unique_id,
    cc.cohort_month,
    cm.order_month,
    (
      (DATE_PART('year', cm.order_month) - DATE_PART('year', cc.cohort_month)) * 12
      + (DATE_PART('month', cm.order_month) - DATE_PART('month', cc.cohort_month))
    )::INTEGER AS cohort_index
FROM customer_months AS cm
JOIN customer_cohorts AS cc USING (customer_unique_id);

-- Cohort counts: number of distinct customers active at each cohort age.
SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM cohort_activity
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;

-- Overall repeat-purchase summary.
WITH customer_orders AS (
    SELECT customer_unique_id, COUNT(DISTINCT order_id) AS delivered_orders
    FROM delivered_order_value
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS customers,
    COUNT(*) FILTER (WHERE delivered_orders >= 2) AS repeat_customers,
    ROUND(
      100.0 * COUNT(*) FILTER (WHERE delivered_orders >= 2) / NULLIF(COUNT(*), 0),
      2
    ) AS repeat_customer_pct,
    ROUND(AVG(delivered_orders), 2) AS avg_delivered_orders_per_customer
FROM customer_orders;
