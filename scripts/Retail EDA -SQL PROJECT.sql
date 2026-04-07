/*
-----------------------------------------Database Exploration---------------------------------------------------

Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
*/

-- Retrieve a list of all tables in the database
SELECT 
    TABLE_CATALOG, 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve all columns for a specific table (dim_customers)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

/*
--------------------------------------------Dimensions Exploration--------------------------------------------------

Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
*/

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT 
    country 
FROM dim_customers
ORDER BY country;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM dbo.products
ORDER BY category, subcategory, product_name;

/*
---------------------------------------------Date Range Exploration--------------------------------------------------
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
*/

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM dim_customers;

/*
-----------------------------------------------------Measures Exploration (Key Metrics)---------------------------------------------------------

Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
*/

-- Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM fact_sales

-- Find how many items are sold
SELECT SUM(quantity) AS total_quantity FROM fact_sales

-- Find the average selling price
SELECT AVG(price) AS avg_price FROM fact_sales

-- Find the Total number of Orders
SELECT COUNT(order_number) AS total_orders FROM fact_sales
SELECT COUNT(DISTINCT order_number) AS total_orders FROM fact_sales

-- Find the total number of products
SELECT COUNT(product_name) AS total_products FROM dbo.products

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM dim_customers;

-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM fact_sales;

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dbo.products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM dim_customers

/*
---------------------------------------------------Magnitude Analysis--------------------------------------------------
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
*/

-- Find total customers by countries
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM dbo.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customers by gender
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM dbo.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
SELECT
    category,
    COUNT(product_key) AS total_products
FROM dbo.products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average cost in each category?
SELECT
    category,
    AVG(cost) AS avg_cost
FROM dbo.products
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM dbo.fact_sales f
LEFT JOIN dbo.products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- What is the total revenue generated by each customer?
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM dbo.fact_sales f
LEFT JOIN dbo.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries?
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM dbo.fact_sales f
LEFT JOIN dbo.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


/*
----------------------------------------------------------Ranking Analysis------------------------------------------------------

Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY

*/

-- Which 5 products Generating the Highest Revenue?
-- Simple Ranking

SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM dbo.fact_sales f
LEFT JOIN dbo.products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Complex but Flexibly Ranking Using Window Functions
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM fact_sales f
    LEFT JOIN dbo.products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;

-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dbo.products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM fact_sales f
LEFT JOIN dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ;



/*
-------------------------------------------------- SALES PERFORMANCE OVER TIME -----------------------------------------------------------
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()

*/

-- Total sales per day
SELECT
order_date,
SUM(sales_amount) as total_sales
FROM fact_sales
WHERE order_date is not Null
GROUP BY order_date
ORDER BY order_date

--Total sales per Year
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) as total_sales
FROM fact_sales
WHERE order_date is not NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

/* We see that 2013 had the highest sales, but we want to know if this is because of more customers or higher sales per customer. Let's add 
the customer count and quantity count to the total sales per year. */

--- Adding customer count to the total sales per year
SELECT
YEAR(order_date)AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity)AS total_quantity
FROM fact_sales
WHERE order_date is not NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- per month
SELECT
YEAR(order_date)AS order_year,
MONTH(order_date)AS order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity)AS total_quantity
FROM fact_sales
WHERE order_date is not NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date)
---- The second i.e February show the least quantity sold
-- OR Using the DATETRUNC() FUNCTION  

SELECT
DATETRUNC(month,order_date)AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity)AS total_quantity
FROM fact_sales
WHERE order_date is not NULL
GROUP BY DATETRUNC(month,order_date)
ORDER BY DATETRUNC(month,order_date)

-- OR using a custom date format using FORMAT FUNCTION 
SELECT
FORMAT(order_date,'yyyy-MMM')AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity)AS total_quantity
FROM fact_sales
WHERE order_date is not NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM')

/*
------------------------------------------------------- CUMULATIVE ANALYSIS-----------------------------------------------------------------
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    
-- Calculate the total sales per month 
-- and the running total of sales over time 

*/
--RUNNING SALES FOR EACH MONTH
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(month,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(month,order_date)
)t
ORDER BY DATETRUNC(month,order_date)




--RUNNING SALES FOR EACH YEAR
SELECT
order_date,
total_sales,
SUM(total_sales) OVER ( ORDER BY order_date) AS running_total_sales
FROM
(
SELECT
DATETRUNC(YEAR,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(YEAR,order_date)
)t
ORDER BY DATETRUNC(YEAR,order_date)


-- MOVING AVERAGE OF THE PRICE
SELECT
order_date,
total_sales,
SUM(total_sales) OVER ( ORDER BY order_date) AS running_total_sales,
AVG(price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(YEAR,order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS price
FROM fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(YEAR,order_date)
)t
ORDER BY DATETRUNC(YEAR,order_date)

/*
--------------------------------------------------PERFORMANCE ANALYSIS-----------------------------------------------------------------------------------------	
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
*/

WITH Yearly_Product_Sales AS
(
SELECT
YEAR(f.order_date)AS order_year,
p.product_name,
SUM(f.sales_amount)AS current_sales
FROM products p
LEFT JOIN fact_sales f 
	ON p.product_key = f.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(f.order_date),p.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name)> 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name)< 0 THEN 'Below Average'
	ELSE 'Average'
END AS avergae_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_previous_year,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)> 0 THEN 'Improved'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)< 0 THEN 'Declined'
	ELSE 'No Change'
END AS performance_change
FROM Yearly_Product_Sales
ORDER BY product_name,order_year

/*
------------------------------------------------PART-TO-WHOLE ANALYSIS-----------------------------------------------------------------------------------------
urpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
-- Which categrory contributes the most to the total sales each year ?
*/ 

WITH Category_Sales AS
(
    SELECT 
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM fact_sales f
    LEFT JOIN products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(
    ROUND(
        (CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100,
        2),'%')AS percentage_contribution
FROM Category_Sales;


----------------------------------------------------DATA SEGMENTATION ANALYSIS-----------------------------------------------------------------------------------------
-- Segment cost into low, medium and high based on the cost distribution of the products and count how many proudcts fall into each range 
WITH product_segments AS 
(
SELECT
product_key,
product_name,
cost,
CASE WHEN  cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
     ELSE 'Above 1000'
END cost_segment
FROM products
)

SELECT 
cost_segment,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_segment
ORDER BY total_products DESC
-- alot of product that dont cost alot, small amout of products cost above 1000 

/* Group customers into three segments based on their spending behaviour.
-VIP: at least 12 months of hostory and sending  more than 5,000
-Regurlar: at least 12 months of history but spendig 5,000 or less
-New:lifespan less than 12 months
and find the total number of customers by each group
*/
WITH customer_spending AS
(
SELECT
    c.customer_key,
    SUM(f.sales_amount) AS total_spending,
    MIN(f.order_date) as first_order,
    MAX(f.order_date) as last_order,
    DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
FROM dbo.fact_sales f
LEFT JOIN dbo.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
    SELECT
    customer_key,
    CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
        ELSE 'New'
    END customer_segment
    FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC

