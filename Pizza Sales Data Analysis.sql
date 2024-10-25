-- Pizza Sales Analysis

-- How many orders were placed this year
SELECT COUNT(order_id) as customer_count
FROM orders_cleaned;

-- What was the total revenue this year
SELECT ROUND(SUM(p.price * od.quantity), 2) as revenue
FROM pizzas_cleaned p
JOIN order_details_cleaned od
	ON p.pizza_id = od.pizza_id;

-- What is the revenue per customer
SELECT ROUND(SUM(p.price * od.quantity) / COUNT(DISTINCT(order_id)), 2) as rev_per_cust
FROM pizzas_cleaned p
JOIN order_details_cleaned od
	ON p.pizza_id = od.pizza_id;

-- What are the average daily customers
SELECT ROUND(AVG(customer_count)) as avg_customers
FROM
(
	SELECT order_date , COUNT(order_id) as customer_count
	FROM orders_cleaned
	GROUP BY order_date
) AS daily_customers;

-- On average, how many pizzas does a customer order
SELECT ROUND(AVG(pizza_count)) AS avg_pizzas_per_order
FROM
(
	SELECT SUM(quantity) as pizza_count
	FROM order_details_cleaned
	GROUP BY order_id
) as pizzas_per_order;
    
-- Are there any peak hours and/or days
SELECT HOUR(order_time) AS hour, COUNT(order_id) as customer_count
FROM orders_cleaned
GROUP BY hour
ORDER BY hour;

SELECT DAYNAME(order_date) AS day, COUNT(order_id) as customer_count
FROM orders_cleaned
GROUP BY day
ORDER BY customer_count DESC;

-- What is the monthly trend in sales. Are there any peak seasons/months
WITH monthly_revenue AS
(
	SELECT DATE_FORMAT(o.order_date, '%Y-%m') as dates,
		   ROUND(SUM(p.price * od.quantity), 2) as revenue
	FROM order_details_cleaned od
	JOIN orders_cleaned o
		ON od.order_id = o.order_id
	JOIN pizzas_cleaned p
		ON od.pizza_id = p.pizza_id
	GROUP BY dates
)
SELECT dates, revenue,
	   ROUND((revenue - LAG(revenue, 1) OVER (ORDER BY dates)) / LAG(revenue, 1) OVER (ORDER BY dates) * 100, 2) AS percentage_change
FROM monthly_revenue;

-- What are the best sellers by revenue and quantity sold
SELECT pt.name, ROUND(SUM(p.price * od.quantity)) as revenue
FROM pizzas_cleaned p
JOIN order_details od
	ON p.pizza_id = od.pizza_id
JOIN pizza_types_cleaned pt
	ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 10;

SELECT pt.name, SUM(od.quantity) as quantity
FROM pizzas_cleaned p
JOIN order_details od
	ON p.pizza_id = od.pizza_id
JOIN pizza_types_cleaned pt
	ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 10;





