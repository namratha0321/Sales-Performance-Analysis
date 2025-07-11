create database amazon;
use amazon;
CREATE TABLE sales_data (
    invoice_id VARCHAR(30),
    branch VARCHAR(5),
    city VARCHAR(30),
    customer_type VARCHAR(30),
    gender VARCHAR(10),
    product_line VARCHAR(100),
    unit_price DECIMAL(10, 2),
    quantity INT,
    VAT FLOAT,
    total DECIMAL(10, 2),
    date DATE,
    time TIME,
    payment_method varchar(100),
    cogs DECIMAL(10, 2),
    gross_margin_percentage FLOAT,
    gross_income DECIMAL(10, 2),
    rating FLOAT
);
select * from sales_data;
-- 1.Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
alter table sales_data
add timeofday varchar(50);
set sql_safe_updates = 0;
UPDATE sales_data
SET timeofday = 
    CASE 
        WHEN HOUR(time) BETWEEN 0 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 16 THEN 'Afternoon'
        ELSE 'Evening'
    END;
set sql_safe_updates = 1;
/* 2.Add a new column named dayname that contains the extracted days of the week on which the given transaction took place 
(Mon, Tue, Wed, Thur, Fri) */
alter table sales_data
add dayname varchar(50); 
update sales_data 
set dayname = dayname(date);
/* 
3. Add a new column named monthname that contains the extracted months of the year on which the given transaction took place 
 (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
*/
alter table sales_data 
add monthname varchar(50); 
update sales_data 
set monthname = MONTHNAME(date);
-- 1.What is the count of distinct cities in the dataset?
select count(distinct city) from sales_data; 
-- 2.For each branch, what is the corresponding city?
select distinct branch, city from sales_data;
-- 3.What is the count of distinct product lines in the dataset?
select distinct product_line from sales_data; 
-- 4.Which payment method occurs most frequently?
select payment_method, count(*)
from sales_data
group by payment_method
order by count(*) desc
limit 1; 
-- 5.Which product line has the highest sales?
select product_line, sum(total)
from sales_data 
group by product_line
order by sum(total) desc
limit 1;  
-- 6.How much revenue is generated each month?
select monthname,sum(total) as revenue
from sales_data
group by monthname
order by revenue desc;
-- 7.In which month did the cost of goods sold reach its peak?
select monthname, sum(cogs)
from sales_data 
group by monthname
order by sum(cogs) desc
limit 1; 
-- 8.Which product line generated the highest revenue?
select product_line, sum(total) as highestrevenue
from sales_data
group by product_line
order by sum(total) desc 
limit 1 ; 
 -- 9 In which city was the highest revenue recorded?
select city, sum(total) as revenuebycity
from sales_data 
group by city
order by sum(total) desc
limit 1; 
-- 10. Which product line incurred the highest Value Added Tax?
select product_line, sum(VAT)
from sales_data 
group by product_line
order by sum(VAT) desc 
limit 1; 
-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT product_line,
       CASE 
           WHEN SUM(total) > (SELECT AVG(total) FROM sales_data) THEN 'Good'
           ELSE 'Bad'
       END AS salesperformance
FROM sales_data
GROUP BY product_line;
-- 12.Identify the branch that exceeded the average number of products sold 
SELECT branch, SUM(quantity) AS total_quantity
FROM sales_data
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales_data);
-- 13. Which product line is most frequently associated with each gender?
SELECT product_line, COUNT(*) AS count
FROM sales_data
WHERE gender = 'Male'
GROUP BY product_line
ORDER BY count DESC
LIMIT 1;
SELECT product_line, COUNT(*) AS count
FROM sales_data
WHERE gender = 'Female'
GROUP BY product_line
ORDER BY count DESC
LIMIT 1;
-- 14.Calculate the average rating for each product line 
select product_line, round(avg(rating),2)
from sales_data 
group by product_line; 
-- 15. Count the sales occurrences for each time of day on every weekday.
SELECT dayname, timeofday, COUNT(*) AS sales_count
FROM sales_data
WHERE dayname NOT IN ('Saturday', 'Sunday')
GROUP BY dayname, timeofday
ORDER BY dayname, timeofday;
-- 16.Identify the customer type contributing the highest revenue. 
select customer_type, sum(total) as highestrevenue  
from sales_data 
group by customer_type 
order by sum(total) desc 
limit 1; 
-- 17.Determine the city with the highest VAT percentage. 
select city , avg(VAT)
from sales_data 	
group by city 
order by avg(VAT) desc 
limit 1; 
-- 18.Identify the customer type with the highest VAT payments. 
select customer_type,sum(VAT) 
from sales_data 
group by customer_type 
order by sum(VAT) desc 
limit 1; 
-- 19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type) 
from sales_data; 
-- 20. What is the count of distinct payment methods in the dataset? 
select count( distinct payment_method) 
from sales_data; 
-- 21.Which customer type occurs most frequently? 
select customer_type, count(*) 
from sales_data 
group by customer_type
order by count(*) desc 
limit 1;
-- 22.Identify the customer type with the highest purchase frequency. 
SELECT customer_type, COUNT(*) AS purchase_count
FROM sales_data
GROUP BY customer_type
ORDER BY purchase_count DESC
LIMIT 1;
-- 23 Determine the predominant gender among customers. 
select gender, count(*)
from sales_data 
group by gender 
order by count(*) desc 
limit 1; 
-- 24 Examine the distribution of genders within each branch. 
select branch, count(gender) as "male count"
from sales_data 
where gender = "Male"
group by branch; 
select branch, count(gender) as " femalecount"
from sales_data 
where gender = "female"
group by branch;
-- 25 Identify the time of day when customers provide the most ratings. 
select timeofday, count(rating)
from sales_data 
group by timeofday 
order by count(rating) desc 
limit 1; 
-- 26 Determine the time of day with the highest customer ratings for each branch. 
SELECT branch, timeofday, avg_rating
FROM (
    SELECT branch, timeofday, AVG(rating) AS avg_rating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM sales_data
    GROUP BY branch, timeofday
) AS ranked_ratings
WHERE rnk = 1;
-- 27 Identify the day of the week with the highest average ratings.
SELECT dayname, AVG(rating) AS avg_rating
FROM sales_data
GROUP BY dayname
ORDER BY avg_rating DESC
LIMIT 1;
-- 28 Determine the day of the week with the highest average ratings for each branch.
SELECT branch, dayname, avg_rating
FROM (
    SELECT branch, dayname, AVG(rating) AS avg_rating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM sales_data
    GROUP BY branch, dayname
) AS ranked_data
WHERE rnk = 1;











