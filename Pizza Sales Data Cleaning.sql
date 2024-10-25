-- Pizza Sales Data Cleaning 

-- Created copy of raw data
CREATE TABLE orders_v1 AS
SELECT *
FROM orders;

CREATE TABLE order_details_v1 AS
SELECT *
FROM order_details;

CREATE TABLE pizzas_v1 AS
SELECT *
FROM pizzas;

CREATE TABLE pizza_types_v1 AS
SELECT *
FROM pizza_types;

-- orders table

-- 1) Remove duplicates
-- Check for duplicates
SELECT *, COUNT(*) as count
FROM orders_v1
GROUP BY order_id, `date`, `time`
HAVING count > 1;

-- 2) Standardize Data
-- Change date and time date type
ALTER TABLE orders_v1 ADD COLUMN order_date DATE;
ALTER TABLE orders_v1 ADD COLUMN order_time TIME;
UPDATE orders_v1
SET
	order_date = STR_TO_DATE(`date`, '%Y-%m-%d'),
    order_time = STR_TO_DATE(`time`, '%H:%i:%s');

-- 3) Check Blank or Null Values
SELECT *
FROM orders_v1
WHERE order_date IS NULL
	  OR order_time IS NULL;  

-- 4) Remove irrelevant date if any
## New column with correct data type added
ALTER TABLE orders_v1 DROP COLUMN `date`;
ALTER TABLE orders_v1 DROP COLUMN `time`;

-- order_details table

-- 1) Remove duplicates
-- Check for duplicates
SELECT *, COUNT(*) AS count
FROM order_details_v1
GROUP BY order_details_id, order_id, pizza_id, quantity
HAVING count > 1;

-- 2) Standardise Data
-- Checks if any pizza_id is incorrect in order details table
SELECT od.pizza_id
FROM order_details_v1 od
LEFT JOIN pizzas_v1 p
	ON od.pizza_id = p.pizza_id
WHERE p.pizza_id IS NULL;

-- Checks if any quantity is incorrect for e.g negative values or outliers
SELECT MIN(quantity), MAX(quantity)
FROM order_details_v1;

-- 3) Check Blank or Null Values
SELECT *
FROM order_details_v1
WHERE order_details_id IS NULL
	  OR order_id IS NULL
      OR pizza_id IS NULL OR pizza_id = ''
      OR quantity IS NULL;

-- pizzas table

-- 1) Remove duplicates
SELECT *, COUNT(*) as count
FROM pizzas_v1
GROUP BY pizza_id, pizza_type_id, size, price
HAVING count > 1;

-- 2) Standardise Data
-- Checks if any pizza_type_id is incorrect in pizzas details table
SELECT p.pizza_type_id
FROM pizzas_v1 p
LEFT JOIN pizza_types_v1 pt
	ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.pizza_type_id IS NULL;

-- Check for incorrect inputs for size
SELECT DISTINCT size
FROM pizzas_v1;

-- Checks if any price is incorrect for e.g negative values or outliers
SELECT MIN(price), MAX(price)
FROM pizzas_v1;

-- 3) Check for blank or null values
SELECT *
FROM pizzas_v1
WHERE pizza_id IS NULL OR pizza_id = ''
	  OR pizza_type_id IS NULL OR pizza_type_id = ''
      OR price IS NULL;

-- pizza_types table

-- 1) Remove duplicates
-- Check duplicates
SELECT *, COUNT(*) as count
FROM pizza_types_v1
GROUP BY pizza_type_id, `name`, category, ingredients
HAVING count > 1;

-- 2) Standardise Data
-- Check for errors in name
SELECT DISTINCT `name`
FROM pizza_types_v1;

-- Check for inccrect category
SELECT DISTINCT category
FROM pizza_types_v1;

-- 3) Check for blanks or nulls
SELECT *
FROM pizza_types_v1
WHERE pizza_type_id IS NULL OR pizza_type_id = ''
	  OR ingredients IS NULL OR ingredients = '';

-- Copy the clean data 
CREATE TABLE orders_cleaned AS
SELECT *
FROM orders_v1;

CREATE TABLE order_details_cleaned AS
SELECT *
FROM order_details_v1;

CREATE TABLE pizzas_cleaned AS
SELECT *
FROM pizzas_v1;

CREATE TABLE pizza_types_cleaned AS
SELECT *
FROM pizza_types_v1;