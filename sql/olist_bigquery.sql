-- Check data first
SELECT * FROM `nantipat-olist-project.olist_raw.orders` 
LIMIT 5; 


-- Check for missing values
SELECT 
    COUNT(*) as total_rows,
    COUNTIF(order_id IS NULL) as null_order_id,
    COUNTIF(order_purchase_timestamp IS NULL) as null_purchase_time,
    COUNTIF(order_delivered_customer_date IS NULL) as null_delivery_date
FROM `nantipat-olist-project.olist_raw.orders`;


-- Check for duplicate values
SELECT 
    order_id, 
    COUNT(*) as count_id
FROM `nantipat-olist-project.olist_raw.orders`
GROUP BY order_id
HAVING count_id > 1;


-- Aftet that i want to create new cleaned table
CREATE OR REPLACE TABLE `nantipat-olist-project.olist_cleaned.master_orders` AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,

    SAFE_CAST(o.order_purchase_timestamp AS TIMESTAMP) AS purchase_at,
    SAFE_CAST(o.order_delivered_customer_date AS TIMESTAMP) AS delivered_at,
    
    c.customer_city,
    c.customer_state,
  
    p.product_category_name, 
    
    i.price,
    i.freight_value,

    DATE_DIFF(
        DATE(SAFE_CAST(o.order_delivered_customer_date AS TIMESTAMP)), 
        DATE(SAFE_CAST(o.order_purchase_timestamp AS TIMESTAMP)), 
        DAY
    ) AS delivery_time_days
    
FROM `nantipat-olist-project.olist_raw.orders` AS o
LEFT JOIN `nantipat-olist-project.olist_raw.customers` AS c ON o.customer_id = c.customer_id
LEFT JOIN `nantipat-olist-project.olist_raw.order_items` AS i ON o.order_id = i.order_id
LEFT JOIN `nantipat-olist-project.olist_raw.products` AS p ON i.product_id = p.product_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- After created table, i've move to work in python on Google Colab to do more deep data cleaning and data analysis.
