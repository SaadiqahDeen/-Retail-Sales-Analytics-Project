/*
=========================================================================================================================
Customer Report
=========================================================================================================================

PURPOSE:
-  This report cosolidates key customer metrics and behaviours

HIGHLIGHTS:
	1.Gather essential fields such as names, ages, and trasaction details.
	2.Segment customers into categories(VIP,Regular,New) and age groups.
	3.Aggregates customer-levelmetrics:
		- Total orders
		-Total sales
		-total quantity purchased
		-total products
		-lifespan (in months)
	4.Calculates vluable KPIs:
		-recency (months since last order)
		-average order value
		-avereage montly spend
*/

--Base query : Retrieves core columns from tabels 
CREATE VIEW dbo.report_customer AS
WITH base_query AS
(
    SELECT 
        f.product_key,
        f.order_date,
        f.order_number,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        c.birthdate,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM fact_sales f
    LEFT JOIN dbo.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS
(
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    -- AGE GROUP LOGIC
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 54 THEN '40-54'
        ELSE '55 and above'
    END AS age_group,

    -- CUSTOMER SEGMENT
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    -- AVERAGE ORDER VALUE (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales/ total_orders
    END AS avg_order_value,

    --AVERAGE MONTHLY SPEND
    CASE 
         WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;