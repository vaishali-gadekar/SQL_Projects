CREATE TABLE store_sales(sale_date date NOT NULL,
                         day_of_year integer NOT NULL,
                         employee_shifts integer,
                         units_sold integer,
                         revenue integer,
                         month_of_year integer)
						 
SELECT * FROM store_sales

/* check 1st 10 rows */
SELECT * FROM store_sales
LIMIT 10

/* check how no. of rows */
SELECT COUNT(*) AS no_of_rows
FROM store_sales

/* check no. of monthly records */
SELECT month_of_year, COUNT(*) FROM store_sales
GROUP BY month_of_year
ORDER BY month_of_year ASC

/* which shift of year has maximum no. of employees */
SELECT employee_shifts, COUNT(*) AS max_no_of_employees FROM store_sales
GROUP BY employee_shifts
ORDER BY COUNT(*) DESC
LIMIT 1

/* which shift of year has minimum no. of employees */
SELECT employee_shifts, COUNT(*) AS max_no_of_employees FROM store_sales
GROUP BY employee_shifts
ORDER BY COUNT(*) ASC
LIMIT 1

/* min, max together */
SELECT MAX(no_of_employees), MIN(no_of_employees) FROM
(SELECT employee_shifts, COUNT(*) AS no_of_employees FROM store_sales
GROUP BY employee_shifts) AS p1

/* min, max employees during per shift of year */
SELECT month_of_year, MAX(employee_shifts), MIN(employee_shifts)
FROM store_sales
GROUP BY month_of_year
ORDER BY month_of_year ASC

--------------------------------------------------------------------

/* total units sold */
SELECT SUM(units_sold) AS total_units_sold 
FROM store_sales 

/* total units sold and avg units sold per month */
SELECT SUM(units_sold) AS total_units_sold , ROUND(AVG(units_sold),2) AS avg_units_sold 
FROM store_sales
GROUP BY month_of_year
ORDER BY month_of_year ASC

--------------------------STANDARD DEVIATION AND VARIANCE-------------------------------------------

/* how spread out the units sold in each month */
/* As we can see from the result, variance values quite high. Because variance measures in squared. 
So better way to get a sense of spread out is standard deviation */
SELECT 
    month_of_year, 
    SUM(units_sold) AS total_unit_sold, 
    ROUND(AVG(units_sold), 2) AS average_unit_sold,
    VAR_POP(units_sold) AS variance_units_sold,
    STDDEV_POP(units_sold) AS std_units_sold
FROM store_sales
GROUP BY month_of_year
ORDER BY month_of_year ASC

/* Interpretation based on data: 
For month 1, it seems like stddev is pretty close around 3.48 across the sales.
However like month 12, it seems like stddev is very large 231.15 across the sales. 
So it seems like in some sales, many units are sold in large quanity and some sales aren't. 
So we can check whether our assumptions are correct or not */
SELECT 
    month_of_year, 
    MIN(units_sold),
    MAX(units_sold)
FROM store_sales
GROUP BY month_of_year
ORDER BY month_of_year ASC

/* When we check the data and our assumptions are correct.
* for 12 month, lowest sales is 0 and largest sale is 879 which leads to large value of stddev.*/ 

---------------------------------PERCENTILES--------------------------------------------

/* Percentiles : One hundreds equal groups; population divided across group
Percentiles help us understand the distribution of data by grouping values into equal sized buckets.
Discrete Percentile: returns value that exists in the column.
Discrete Percentile is very useful when you want to know the value in the column, that falls into a percentile.
Continuous Percentile: interpolates the boundary value between the percentiles.
Continuous Percentile is very useful when you want to know what is the value at the boundary between two percentile buckets.
Differences between Discrete and Continuous Percentile : */

SELECT * FROM store_sales

/* What are the top sales data ? */
/* Data Interpretion: 
it seems like top sales are coming from 12 month, which is not suprising due to seasonality trend of holidays */

SELECT * FROM store_sales
ORDER BY revenue DESC
LIMIT 10

/* What about average of sales ? */
SELECT AVG(revenue) FROM store_sales

/* the average revenue is about 5806.16$ but it doesn't tell us the full story, like
- Are there many days with low sales?
- Are there many days with high sales? 
- or our sales evenly distributed across all days? */

/* we can use percentiles to answer above question and understand our data distributions */

------------------PERCENTILE DISCRETE FUNCTION-----------------------------------

/* get 50 percentile of revenue */
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_50_percent
FROM store_sales

----it seem like 50 percentile of revenue 5856$ is not too far off from the average sales 5806.16$

/* let's look at 50th, 60th , 90th , 95th percentiles */
SELECT PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_50_percent,
PERCENTILE_DISC(0.6) WITHIN GROUP (ORDER BY revenue) AS revenue_60_percent,
PERCENTILE_DISC(0.9) WITHIN GROUP (ORDER BY revenue) AS revenue_90_percent,
PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY revenue) AS revenue_95_percent
FROM store_sales

------------------PERCENTILE CONTINUOUS FUNCTION----------------------------------

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS revenue_50_per
FROM store_sales

------------------------CORRELATION AND RANKS-------------------------------------------------

SELECT * FROM store_sales

/* check the correlation between revenue and unit sold */
SELECT CORR(revenue, units_sold) FROM store_sales

--we can see that there is high correlation between revenue and units sold, which make sense.

/* What about correlation between unit sold and number of employees on shift? */
SELECT CORR(units_sold, employee_shifts) FROM store_sales

--As per the result, there is a positive correlation of 0.5593 but not as strong as between units sold and revenue.

/* What about correlation between unit sold and month of the year */
SELECT CORR(units_sold, month_of_year) FROM store_sales

--As per the result, there is a very very low positive correlation of 0.128.
--which again make sense because month value increase from 1 to 12 and revenue gets high on december although these 1, 2,..1
--numbers shouldn't have correlation with the unit sold.

------------------------------ROW NUMBER----------------------------------------------

/* Row Number is a window function which operates on ordered set. It is added as a new column to the result.
It is very useful when we want to assign row order based on the ordered list.*/

/* We want to add a row number based on the units sold */
SELECT units_sold, ROW_NUMBER() OVER(ORDER BY units_sold) AS row_num 
FROM store_sales

/* We also want to know the standing (rank) of month_of_year based on the units sold */
SELECT month_of_year, units_sold, ROW_NUMBER() OVER(ORDER BY units_sold) AS row_num 
FROM store_sales
ORDER BY month_of_year

--------------------------------MODE-------------------------------------------------------------------

/* What is the frequently occuring numbers of employee per shift in each month? */
SELECT month_of_year, employee_shifts, COUNT(*) AS mode FROM store_sales
GROUP BY employee_shifts, month_of_year
ORDER BY COUNT(*) DESC

--we can see that May through July and December are the months which have most number of employee on shifts.

---------------------------LINEAR MODELS-------------------------------------

/* Linear Model such as regression are useful for estimating values for business.
Such as: We just run an advertising campaign and expect to sell more items than usual.
How many employees should we have working? */

/* Computing Intercept (employee shifts on y-axis and units sold on x-asis) */
SELECT REGR_INTERCEPT(employee_shifts, units_sold) FROM store_sales

/* What if we want to know number of units sold based on the the employees on shift? */
SELECT REGR_INTERCEPT(units_sold, employee_shifts) FROM store_sales

-----------------------------SLOPE------------------------------------------

/* Computing Slope (employee shifts on y-axis and units sold in x-asis) */
SELECT REGR_SLOPE(employee_shifts, units_sold) FROM store_sales

-------------------------LINEAR REGRESSION---------------------------------
/* Linear Regression: y=mx+b
The ultimate question: How many employees we should have working to accomodate the sales of 1,500 items? */
SELECT  REGR_SLOPE(employee_shifts, units_sold)*1500 + 
REGR_INTERCEPT(employee_shifts, units_sold) AS employee_num FROM store_sales

--Based on the results, we expect to have 7.26 (around 7 employees) to handle to sales of 1,500 items.

