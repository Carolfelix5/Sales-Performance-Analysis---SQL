SELECT *
FROM sales_data
LIMIT 5;

SELECT COUNT(*)
FROM sales_data;

-- Total_sales, How much revenue did the company generate?
SELECT SUM(sales) AS total_sales
FROM sales_data;

-- Total_profit, Companies care more about profit than revenue.
SELECT SUM(profit) AS total_profit
FROM sales_data;

-- Total Quantity Sold, Shows overall demand.
SELECT SUM(quantity) AS total_quantity_sold
FROM sales_data;

-- Number of Orders, Counts every transaction.
SELECT COUNT(*) AS total_order
FROM sales_data;

--Sales by Category, Which category generates the highest revenue?
SELECT 
	category, 
	SUM(sales) AS total_sales
FROM sales_data
GROUP BY category
ORDER BY total_sales DESC;

--Profit by Category,
SELECT 
	category,
	SUM(sales) AS total_profit
FROM sales_data
GROUP BY category
ORDER BY total_profit DESC;

--Sales by Region, Identify strongest markets.
SELECT 
	region,
	SUM(sales) AS total_sales
FROM sales_data
GROUP BY region
ORDER BY total_sales DESC;

--Profit by Region,
SELECT
	region,
	SUM(profit) AS total_profit
FROM sales_data
GROUP BY region
ORDER BY total_profit DESC;

--Top Products by Sales, Management only wants top performers.
SELECT
	product_name,
	SUM(sales) AS total_sales
FROM sales_data
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

--Most Profitable Products,
SELECT
	product_name,
	SUM(profit) AS total_profit
FROM sales_data
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

--Monthly Sales Trend
SELECT
	DATE_TRUNC('month', order_date) AS month,
	SUM(sales) AS total_sales
FROM sales_data
GROUP BY month
ORDER BY month;

--or
SELECT
	EXTRACT (YEAR FROM order_date) AS year,
	EXTRACT(MONTH FROM order_date) AS month,
	SUM(sales) 
FROM sales_data
GROUP BY year, month
ORDER BY year, month DESC;

-- Monthly Profit Trends
SELECT 
	DATE_TRUNC('month', order_date) AS month,
	SUM(profit) AS total_profit
FROM sales_data
GROUP BY month
ORDER BY month;

--Best Month Ever
SELECT
	DATE_TRUNC('month', order_date) AS month,
	SUM(sales) AS total_sales
FROM sales_data
GROUP BY month
ORDER BY total_sales DESC
LIMIT 1;

--Running Monthly Sales
WITH monthly_sales AS
(
	SELECT 
		DATE_TRUNC('month',order_date) AS month,
		SUM(sales) AS monthly_sales
	FROM sales_data
	GROUP BY month
)
SELECT
	month,
	monthly_sales,
	SUM(monthly_sales) 
		OVER(ORDER BY month)
		AS running_sales
FROM monthly_sales;

--Rank Products by Revenue
SELECT
	product_name,
	SUM(sales) AS revenue,
	RANK()OVER(
		ORDER BY SUM(sales) DESC
	) AS rank
FROM sales_data
GROUP BY product_name;

--Top Product in Each Category
WITH product_sales AS
(
	SELECT
    	category,
		product_name,
		SUM(sales) AS revenue,
		ROW_NUMBER() OVER
		(
			PARTITION BY category
			ORDER BY SUM(sales) DESC
		) as rn
	FROM sales_data
	GROUP BY category, product_name
)

SELECT *
FROM product_sales
WHERE rn = 1;

-- Profit Margin by Category
SELECT
	category,
	ROUND(
		SUM(profit)* 100.0
		/SUM(sales),
		2
	) AS profit_margin
FROM sales_data
GROUP BY category
ORDER BY profit_margin DESC;

--Least Profitable Products
SELECT
	product_name,
	SUM(profit) AS total_profits
FROM sales_data
GROUP BY product_name
ORDER BY total_profits ASC
LIMIT 10;

--Which Region Has Highest Profit Margin?
SELECT
	region,
	ROUND(
		SUM(profit) * 100.0
		/ SUM(sales),
		2
	) AS profit_margin
FROM sales_data
GROUP BY region
ORDER BY profit_margin DESC;

--Average Order Value
SELECT
	ROUND(
	SUM(sales)/ COUNT(*),
	2
	)
FROM sales_data

--Products with Negative Profit

SELECT
    product_name,
    SUM(profit) AS total_profit
FROM sales_data
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit;


--Category-wise Running Sales
WITH category_sales AS
(
	SELECT
		category,
		DATE_TRUNC('month',order_date) AS month,
		SUM(sales) AS monthly_sales
	FROM sales_data
	GROUP BY category, month
)

SELECT
	category,
	month,
	monthly_sales,
	SUM(monthly_sales) OVER
	(
		PARTITION BY category
		ORDER BY month
	) AS running_sales
FROM category_sales;
