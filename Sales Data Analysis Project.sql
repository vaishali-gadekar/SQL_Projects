CREATE TABLE sales(order_id int,
				   product varchar(50),
				   quantity_ordered int,
				   price_each money,
				   order_date timestamp,
				   purchase_address varchar(50),
				   month int,
				   sales money,
				   city varchar(50),
				   hour int)

SELECT * FROM sales

COPY sales(order_id, product, quantity_ordered, price_each, order_date, purchase_address, month, sales, city, hour)
FROM'C:\Users\sagar\Downloads\Sales Data - Sales Data.csv'
DELIMITER ','
CSV HEADER;

/* Row count */
SELECT COUNT(*) FROM sales AS row_count

/* Check Table Information */
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'sales'

/* checking null values */
SELECT * FROM sales
WHERE (SELECT column_name FROM information_schema.columns
WHERE table_name = 'sales') = NULL

/* Data Cleaning */
UPDATE amazon_movies
SET imdb_rating = CASE WHEN TRIM(imdb_rating) = 'none' THEN NULL 
                       ELSE CAST(TRIM(imdb_rating) AS FLOAT) END
WHERE TRIM(imdb_rating) NOT IN ('None', '')

ALTER TABLE amazon_movies
ALTER COLUMN imdb_rating :: numeric

UPDATE amazon_movies
SET imdb_rating = '0'
WHERE imdb_rating = 'none'

UPDATE amazon_movies
REPLACE (imdb_rating,'none','0') from amazon_movies

select * from sales

-----------TOTAL SALES ANALYSIS-----------

/* What is the total revenue generated from all sales. */
SELECT SUM(sales)  AS total_revenue FROM sales 

/* What is the average order value (total sales divided by the number of orders). */
SELECT SUM(sales)/SUM(quantity_ordered) AS avg_order_value FROM sales

/* What is the total quantity of products sold. */
SELECT SUM(quantity_ordered) AS total_products_sold FROM sales

-----------PRODUCT ANALYSIS-----------

/* Which products are the top-selling items based on quantity and revenue. */
SELECT product, SUM(quantity_ordered) AS quantity, SUM(sales) AS revenue FROM sales
GROUP BY product
ORDER BY SUM(sales) DESC

/* What is the average price of products sold. */
SELECT ROUND(AVG(CAST(price_each AS NUMERIC)),2) AS avg_price FROM sales

/* Are there any products with consistently high sales throughout the year. */
SELECT product, SUM(sales) FROM sales
GROUP BY product
ORDER BY SUM(sales) DESC
LIMIT 5

/* How many unique products were sold. */
SELECT COUNT(DISTINCT product) AS no_of_unique_products FROM sales

/* Which product had the highest total revenue. */
SELECT product, SUM(sales) FROM sales
GROUP BY product
ORDER BY SUM(sales) DESC
LIMIT 1

-----------MONTHLY SALES TREND-----------
select * from sales

/* How does the total sales vary across different months. */
SELECT EXTRACT(MONTH FROM order_date) AS month, SUM(sales) AS total_sales 
FROM sales 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY SUM(sales) DESC

/* Which months have the highest and lowest sales. */
SELECT EXTRACT(MONTH FROM order_date) AS month, SUM(sales) AS highest_sale
FROM sales 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY SUM(sales) DESC
LIMIT 1

SELECT EXTRACT(MONTH FROM order_date) AS month, SUM(sales) AS lowest_sale
FROM sales 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY SUM(sales) ASC
LIMIT 1

-----/* Is there any seasonality in the sales data. */
SELECT EXTRACT(MONTH FROM order_date) AS month, SUM(sales) AS total_sales 
FROM sales 
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY SUM(sales) DESC------

-----------GEOGRAPHICAL ANALYSIS-----------
select * from sales

/* Which cities have the highest sales. */
SELECT SPLIT_PART(purchase_address, ',', 2) AS city, SUM(sales) AS total_sales FROM sales
GROUP BY SPLIT_PART(purchase_address, ',', 2)
ORDER BY SUM(sales) DESC
LIMIT 1

/* Are there any regional trends in product preferences or sales. */
SELECT SPLIT_PART(purchase_address, ',', 2) AS city, 
product, SUM(sales) AS total_sales FROM sales
GROUP BY SPLIT_PART(purchase_address, ',', 2), product
ORDER BY SPLIT_PART(purchase_address, ',', 2), SUM(sales) DESC

-----------TIME BASED ANALYSIS-----------

/* What time of day (hour) sees the highest order volume. */
SELECT hour, SUM(quantity_ordered) as order_quantity FROM sales
GROUP BY hour
ORDER BY  SUM(quantity_ordered) DESC
LIMIT 1
--i.e AT 7.00 PM orders are maximum

/* Is there a correlation between the time of day and the value of sales. */
SELECT hour, SUM(sales) as total_sales FROM sales
GROUP BY hour
ORDER BY  SUM(sales) DESC
LIMIT 1
--i.e AT 7.00 PM orders are maximum so sales amount is also high that time

/* Are there any specific hours or time periods that consistently have low sales. */
SELECT hour, ROUND(AVG(CAST(sales AS NUMERIC)),2) as avg_sales FROM sales
GROUP BY hour
ORDER BY ROUND(avg(CAST(sales AS NUMERIC)),2) ASC
--i.e. AT 5.00 AM sales are less

-----------SALES BY DAY OF WEEK-----------

/* Do certain days of the week have higher sales compared to others. */
SELECT TO_CHAR(order_date, 'Day') AS day, SUM(sales) AS total_sales FROM sales
GROUP BY TO_CHAR(order_date, 'Day')
ORDER BY SUM(sales) DESC
LIMIT 1

-----------ANALYSIS OF HIGH VALUE OREDERS-----------

/* Are there any orders with exceptionally high sales values. */
SELECT order_id, sales FROM sales
WHERE CAST(sales AS NUMERIC) > (SELECT ROUND(avg(CAST(sales AS NUMERIC)),2) * 10 FROM sales)

/* What are the characteristics of these high-value orders? (e.g., products, locations) */
SELECT * FROM sales 
WHERE order_id IN
(SELECT order_id FROM sales
WHERE CAST(sales AS NUMERIC) > (SELECT ROUND(avg(CAST(sales AS NUMERIC)),2) * 10 FROM sales))











