/*
PRODUCT REPORT 

Purpose:This report consolidates key product metrics and behaviours

highlights :
1. Gather essential fields  such as product name, category, subcategory and cost.
2. Segment products by revenue to i dentify  High-performers, mid-range and low performers 
3. Aggregates product-level metrics:
	- Total orders
	- Total sales
	- Total quantity sold
	- Total customers (unique)
	- lifespan (in months)
4. Calculates valuable KPIs:
		-recency (months since last order)
		-average order revenue
		-average montly revenue
*/
CREATE VIEW dbo.report_product AS
WITH base_query AS
(
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,

        f.order_number,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.customer_key
    FROM fact_sales f
    LEFT JOIN products p
        ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
),
product_aggregation AS
(
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,

        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,

        -- ⭐ AVERAGE SELLING PRICE (ASP)
        CASE 
            WHEN SUM(quantity) = 0 THEN 0
            ELSE SUM(sales_amount) * 1.0 / SUM(quantity)
        END AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,

    CASE
        WHEN total_sales >= 50000 THEN 'High Performer'
        WHEN total_sales BETWEEN 10000 AND 49999 THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS performance_segment,

    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,

    DATEDIFF(month, last_order_date, GETDATE()) AS recency_months,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/ total_orders
    END AS avg_order_revenue,

    ROUND(avg_selling_price, 1) AS avg_selling_price

FROM product_aggregation;