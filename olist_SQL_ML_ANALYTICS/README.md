# Olist E-Commerce Analytics Project

## 📊 Project Overview

This project demonstrates advanced **SQL analytics** on a real-world e-commerce dataset (Olist, Brazil). The goal is to extract actionable business insights from orders, customers, products, and reviews. This complements my AI & Data Science skills and backend experience, bridging **data analysis** with **business strategy**.

Key highlights:  
- Real business-oriented dataset with **100k+ orders, 40k+ customers, and 10k+ products**.  
- 25+ **optimized SQL queries** answering realistic business questions.  
- Clean schema design with relationships for analytical and operational queries.  
- Insights ready for dashboards, reporting, or further ML applications.  

---

## 🗂 Dataset

**Source:** [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  

**Tables & Description:**

| Table | Primary Key | Notes |
|-------|-------------|-------|
| `customers` | `customer_id` | Customer info: unique IDs, state, etc. |
| `orders` | `order_id` | Order timestamps, status, customer reference |
| `order_items` | `order_item_id` | Items per order with `product_id`, `price`, `freight_value` |
| `products` | `product_id` | Product details and category |
| `sellers` | `seller_id` | Seller info |
| `order_reviews` | `review_id` | Customer reviews with scores and comments |

**Relationships:**
customers ---< orders ---< order_items >--- products
              |
              >--- order_reviews
sellers ---< order_items


---

## 🔍 Business Questions & SQL Queries

Below are examples of **realistic business-focused questions** along with the type of queries used:

| No | Business Question | Description / SQL Approach |
|----|-----------------|----------------------------|
| 1  | Monthly revenue trend | Orders grouped by month (`SUM(price + freight_value)`), revenue growth % |
| 2  | Top 10 products by revenue | Join `order_items` + `products`, group by `product_id` |
| 3  | Revenue per state | Join `customers` + `orders` + `order_items`, group by `customer_state` |
| 4  | Top 10% customers by revenue | Use `ROW_NUMBER()` over total revenue per customer |
| 5  | Repeat customer % | Count customers with more than 1 order |
| 6  | Average delivery delay per product category | `DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)` |
| 7  | Late vs on-time orders | Use CASE statements to count late/on-time deliveries |
| 8  | Freight cost % of total revenue | `SUM(freight_value) / SUM(price + freight_value)` |
| 9  | Top reviewed products | Join `order_reviews`, group by `product_id`, order by total reviews |
| 10 | Average revenue per customer | Sum per customer, then average |
| 11 | Customer lifetime value (LTV) | Sum revenue per customer over time |
| 12 | Month-over-month revenue growth | Use window functions with `LAG()` |
| 13 | Products causing most delivery delays | Join orders + order_items + products, group by category |
| 14 | States with highest avg order value | Total revenue / total orders per state |
| 15 | Customers generating 50% revenue | Cumulative revenue calculation per customer |
| 16 | Categories with highest return rates | Count canceled or refunded orders per category |
| 17 | Average review score per product category | Join reviews + products, group by category |
| 18 | Percentage of orders delivered late | Use CASE statement on delivery dates |
| 19 | Sellers with highest revenue | Aggregate by seller_id |
| 20 | Products with highest revenue but low review score | Join orders + reviews + products, filter on avg review score |
| 21 | Avg delivery delay per seller | Join order_items + orders + sellers |
| 22 | Top customers by repeat purchase frequency | Count orders per customer, order descending |
| 23 | Revenue contribution of top 10% customers | Sum revenue for top 10% customers using window functions |
| 24 | Freight cost impact on revenue per product | Sum freight / sum total price+freight per product |
| 25 | Product category correlation with review scores | Avg review per category |

> ⚡ All queries are optimized using **JOINs**, **window functions**, and **aggregations**, mimicking real-world analytics pipelines.

---

## 📈 Sample Insights

- **Freight represents 14.21% of total revenue** — shipping is a significant cost factor.  
- **Repeat customers are only 3.12%** — potential opportunity for loyalty programs.  
- **Top 10% of customers generate a major portion of revenue** — focus marketing on high-value customers.  
- Some **product categories consistently deliver late** — operational improvement needed.  
- **SP, RJ, MG states contribute most of the revenue** — regional targeting can boost sales.  
- Product reviews correlate with delivery performance: late deliveries often have lower ratings.  

---

## 📂 GitHub Repository Structure
Olist-Ecommerce-Analytics/
│
├─ SQL/
│ ├─ schema.sql # Table creation scripts
│ ├─ queries.sql # All 25+ SQL queries
│
├─ CSV/
│ ├─ MODEL_DATA.CSV
│
├─ VISUALS/
│  │── PNGS OF GRAPHS ETC..
│
└─ README.md 

