USE sql_store;

SELECT * FROM sql_store.customers;


-- Top 5 customers by points
CREATE VIEW top_5_customers AS
SELECT customer_id, 
		first_name,
        last_name,
        points
FROM customers
ORDER BY points DESC
LIMIT 5;


-- 5 Oldest customers 
CREATE VIEW oldest_5_customers AS
SELECT customer_id, 
		first_name,
		last_name, 
        birth_date
FROM customers
ORDER BY birth_date ASC
LIMIT 5;


-- Customers located in CA, VA, FL
SELECT customer_id, first_name, last_name, state
FROM customers
WHERE state IN ('CA', 'VA', 'FL');


-- Return customers without phone number
SELECT first_name, last_name, phone
FROM customers
WHERE phone IS NULL;


-- Get the customers who have placed an order
SELECT order_id,
	   first_name,
	   last_name
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
ORDER BY order_id;
-- These customers have placed one or more orders


-- Get the customers' orders that are not shipped
SELECT order_id,
		first_name,
        last_name,
        shipper_id
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
WHERE shipper_id IS NULL;



-- Get the status of the orders
SELECT order_id, 
	   order_date,
	   first_name,
	   last_name,
	   name AS order_status
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
JOIN order_statuses os
	ON o.status = os.order_status_id
ORDER BY o.order_id;



-- Get the customers orders with the respective product name and IDs
SELECT o.order_id,
		first_name,
        last_name,
		p.name AS product_name,
		oi.product_id, 
        quantity, 
        oi.unit_price
FROM order_items oi
JOIN products p 
	ON oi.product_id = p.product_id
JOIN orders o 
	ON oi.order_id = o.order_id
JOIN customers c
	ON o.customer_id = c.customer_id
ORDER BY order_id;



-- Get the name of the shippers name
SELECT o.order_id,
		o.order_date,
		sh.name AS shipper_name,
		o.shipped_date
FROM orders o
JOIN shippers sh
	ON o.shipper_id = sh.shipper_id
ORDER BY o.order_id;






