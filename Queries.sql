SELECT * FROM restaurant;


--case study answers

-- 1. Total Revenue
SELECT sum( Amount) AS total_revenue
FROM restaurant;
-- 2. Daily revenue
SELECT  order_date,sum(amount) AS daily_revenue
FROM restaurant
GROUP BY order_date
ORDER BY order_date;
-- 3. Peak sales days
SELECT order_date,sum( amount) AS total
FROM restaurant
GROUP BY order_date
ORDER BY total DESC
LIMIT 5;
-- 4.  Hourly insights
SELECT DATE_PART('hour', time_of_order) AS HOUR, SUM(amount) AS revenue
FROM restaurant
GROUP BY HOUR
ORDER BY revenue DESC;
-- 5. Busiest hour
SELECT DATE_PART('hour', time_of_order) AS HOUR, COUNT(*) AS total_orders
FROM restaurant
GROUP BY HOUR
ORDER BY total_orders DESC;
-- 6. Top selling items
SELECT item,sum( amount) AS sales
FROM restaurant
GROUP BY item
ORDER BY sales 
DESC LIMIT 10;


-- 7. Top selling categories
SELECT m.category,sum(r.amount) AS Total_sales
FROM menu m 
LEFT JOIN restaurant r ON 
m.item=r.item
GROUP BY m.category
ORDER BY Total_sales DESC
LIMIT 10;
-- 8.  Least selling categories
SELECT m.category,sum(r.amount) AS Total_sales
FROM menu m 
LEFT JOIN restaurant r ON 
m.item=r.item
GROUP BY m.category
ORDER BY Total_sales ASC
LIMIT 10;
-- 9. Top selling items by qty sold and revenue
SELECT  r.item,sum(r.amount) AS revenue,sum(r.quantity) AS qty_sold
FROM restaurant r 
GROUP BY r.item
ORDER BY revenue DESC,qty_sold DESC
LIMIT 10;
-- 10. Least selling items by qty sold and revenue
SELECT  r.item,sum(r.amount) AS revenue,sum(r.quantity) AS qty_sold
FROM restaurant r 
GROUP BY r.item
ORDER BY revenue,qty_sold ASC
LIMIT 10;
-- 11. Average_order value
SELECT 
    order_date,
    ROUND(CAST(SUM(amount) * 1.0 / COUNT(DISTINCT order_id) AS NUMERIC), 2) AS average_order_value
FROM restaurant 
GROUP BY order_date
ORDER BY order_date;
-- 12. Average_item price
SELECT round( CAST(sum(Price)*1.0/count(DISTINCT m.item_id) AS NUMERIC),2) AS average_item_value
FROM menu m;
-- 13. Total revenue from each item
SELECT r.item,sum(amount) AS Revenue
FROM restaurant r
GROUP BY r.item
ORDER BY revenue DESC;
-- 14.  Busiest day each week as per total sales
WITH weekly_sales AS (
  SELECT 
    DATE_TRUNC('week', order_date) AS week_start,
    order_date,
    SUM(amount) AS total_sales
  FROM restaurant
  GROUP BY DATE_TRUNC('week', order_date), order_date
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (PARTITION BY week_start ORDER BY total_sales DESC) AS day_rank
  FROM weekly_sales
)
SELECT week_start, order_date AS busiest_day, total_sales
FROM ranked_sales
WHERE day_rank = 1;


-- 15. Busiest day each week as per total no of orders
WITH weekly_sales AS (
  SELECT 
    DATE_TRUNC('week', order_date) AS week_start,
    order_date,
    count(order_id) AS total_orders
  FROM restaurant
  GROUP BY DATE_TRUNC('week', order_date), order_date
),
ranked_sales AS (
  SELECT *,
         RANK() OVER (PARTITION BY week_start ORDER BY total_orders DESC) AS day_rank
  FROM weekly_sales
)
SELECT week_start, order_date AS busiest_day, total_orders
FROM ranked_sales
WHERE day_rank = 1;

-- 16. Day of week performance
SELECT TO_CHAR(order_date, 'Day') AS weekday, SUM(amount) AS revenue
FROM restaurant
GROUP BY weekday
ORDER BY revenue DESC;


-- 17. Item trends over time

SELECT order_date, item, SUM(quantity) AS total_sold
FROM restaurant
GROUP BY order_date, item
ORDER BY order_date, item ;

-- 18. Daily growth rate
WITH daily_sales AS (
    SELECT
        order_date,
        SUM(amount) AS total_sales
    FROM
        restaurant
    GROUP BY
        order_date
),
growth_calc AS (
    SELECT
        order_date,
        total_sales,
        LAG(total_sales) OVER (ORDER BY order_date) AS previous_day_sales
    FROM
        daily_sales
)
SELECT
    order_date,
    total_sales,
    previous_day_sales,
    ROUND(
        (100 * (total_sales - previous_day_sales) / NULLIF(previous_day_sales, 0))::NUMERIC,
        2
    ) AS daily_growth_percent
FROM
    growth_calc
ORDER BY
    order_date;