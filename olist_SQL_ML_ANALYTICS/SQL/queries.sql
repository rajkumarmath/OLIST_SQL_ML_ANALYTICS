-- ================================================
-- Olist E-Commerce Analytics Queries
-- ================================================

-- 1️⃣ Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 2️⃣ Top 10 products by revenue
SELECT
    oi.product_id,
    p.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id, p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3️⃣ Revenue per state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- 4️⃣ Top 10% customers by revenue
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
ranked_customers AS (
    SELECT
        customer_unique_id,
        total_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rn,
        COUNT(*) OVER () AS total_customers
    FROM customer_revenue
)
SELECT *
FROM ranked_customers
WHERE rn <= 0.1 * total_customers;

-- 5️⃣ Repeat customer percentage
SELECT
    ROUND(
        (COUNT(DISTINCT customer_unique_id) -
        COUNT(DISTINCT CASE WHEN order_count = 1 THEN customer_unique_id END)
        ) / COUNT(DISTINCT customer_unique_id) * 100, 2
    ) AS repeat_customer_percentage
FROM (
    SELECT c.customer_unique_id, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) t;

-- 6️⃣ Average delivery delay per product category
SELECT
    p.product_category_name,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delivery_delay,
    COUNT(*) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY avg_delivery_delay DESC
LIMIT 10;

-- 7️⃣ Late vs on-time orders per product category
SELECT
    p.product_category_name,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    SUM(CASE WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS on_time_orders,
    COUNT(*) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY late_orders DESC;

-- 8️⃣ Freight cost percentage of total revenue
SELECT
    ROUND(SUM(oi.freight_value) / SUM(oi.price + oi.freight_value) * 100, 2) AS freight_percentage
FROM order_items oi;

-- 9️⃣ Top reviewed products
SELECT
    oi.product_id,
    p.product_category_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY oi.product_id, p.product_category_name
ORDER BY total_reviews DESC
LIMIT 5;

-- 🔹 Additional queries for full portfolio

-- 10️⃣ Average revenue per customer
SELECT
    ROUND(AVG(customer_total), 2) AS avg_revenue_per_customer
FROM (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS customer_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) t;

-- 11️⃣ Customer lifetime value
SELECT
    c.customer_unique_id,
    SUM(oi.price + oi.freight_value) AS lifetime_value,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 10;

-- 12️⃣ Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS revenue_growth_pct
FROM monthly_revenue;

-- 13️⃣ Products causing most delivery delays
SELECT
    p.product_category_name,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
    COUNT(*) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY p.product_category_name
ORDER BY late_orders DESC
LIMIT 10;

-- 14️⃣ States with highest average order value
SELECT
    c.customer_state,
    ROUND(SUM(oi.price + oi.freight_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;

-- 15️⃣ Customers generating 50% of total revenue
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT *
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 50; -- approximate for illustration

-- 16️⃣ Categories with highest return rates (cancelled orders)
SELECT
    p.product_category_name,
    SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled_orders,
    COUNT(*) AS total_orders
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_category_name
ORDER BY canceled_orders DESC
LIMIT 10;

-- 17️⃣ Average review score per product category
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC
LIMIT 10;

-- 18️⃣ Percentage of orders delivered late
SELECT
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS late_percentage
FROM orders o
WHERE o.order_delivered_customer_date IS NOT NULL;

-- 19️⃣ Sellers with highest revenue
SELECT
    s.seller_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS seller_revenue
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id
ORDER BY seller_revenue DESC
LIMIT 10;

-- 20️⃣ Products with high revenue but low review
SELECT
    oi.product_id,
    p.product_category_name,
    SUM(oi.price + oi.freight_value) AS total_revenue,
    ROUND(AVG(r.review_score), 2) AS avg_review
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY oi.product_id, p.product_category_name
HAVING avg_review < 3.5
ORDER BY total_revenue DESC
LIMIT 10;

-- 21️⃣ Average delivery delay per seller
SELECT
    s.seller_id,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delivery_delay
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY s.seller_id
ORDER BY avg_delivery_delay DESC
LIMIT 10;

-- 22️⃣ Top customers by repeat purchase frequency
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;

-- 23️⃣ Revenue contribution of top 10% customers
WITH customer_revenue AS (
    SELECT
        c.customer_unique_id,
        SUM(oi.price + oi.freight_value) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT ROUND(SUM(total_revenue), 2) AS top_10_percent_revenue
FROM (
    SELECT total_revenue
    FROM customer_revenue
    ORDER BY total_revenue DESC
    LIMIT 9610 -- replace with actual 10% number of customers
) t;

-- 24️⃣ Freight cost impact per product
SELECT
    p.product_category_name,
    ROUND(SUM(oi.freight_value) / SUM(oi.price + oi.freight_value) * 100, 2) AS freight_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY freight_pct DESC
LIMIT 10;

-- 25️⃣ Product category correlation with review scores
SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(r.review_id) AS total_reviews
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_reviews r ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY avg_review_score DESC;
