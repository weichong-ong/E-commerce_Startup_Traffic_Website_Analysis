-- Product-Level Sales
SELECT 
YEAR(created_at) as yr,
MONTH(created_at) as mo,
COUNT(DISTINCT order_id) as number_of_sales,
SUM(price_usd) as total_revenue,
SUM(price_usd-cogs_usd) as total_margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY 1,2;

-- Product Launches
SELECT DISTINCT primary_product_id
FROM orders
WHERE created_at BETWEEN '2012-04-01' AND '2013-04-05';

SELECT 
YEAR(ws.created_at) as yr,
MONTH(ws.created_at) as mo,
COUNT(DISTINCT o.order_id) as orders,
COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) as conv_rate,
SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) as revenue_per_session,
COUNT(CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END) as product_1_orders,
COUNT(CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END) as product_2_orders
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-03-31'
GROUP BY 1,2;

-- Product-Level Website Pathing
-- Step 1: Find all /products pageview_id
DROP TEMPORARY TABLE IF EXISTS product_pageview_id_table;
CREATE TEMPORARY TABLE product_pageview_id_table
SELECT website_session_id, website_pageview_id as product_pageview_id,
CASE
	WHEN created_at BETWEEN '2012-10-06' AND '2013-01-06' THEN 'A.Pre_Product_2'
    WHEN created_at BETWEEN '2012-01-06' AND '2013-04-06' THEN 'B.Post_Product_2'
    ELSE 'out of period'
    END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
AND pageview_url = '/products'
ORDER BY website_session_id;

SELECT * FROM product_pageview_id_table;

-- Step 2: Find next min pageview_id after /products
DROP TEMPORARY TABLE IF EXISTS next_min_pageview_id_table;
CREATE TEMPORARY TABLE next_min_pageview_id_table
SELECT 
pp.time_period,
pp.website_session_id,
MIN(wp.website_pageview_id) as next_min_pageview_id
FROM product_pageview_id_table pp
LEFT JOIN website_pageviews wp ON pp.website_session_id = wp.website_session_id
AND wp.website_pageview_id > pp.product_pageview_id
GROUP BY 1,2;

SELECT * FROM next_min_pageview_id_table;

-- Step 3: Find out the pageview_url of next min pageview_id after /products
DROP TEMPORARY TABLE IF EXISTS next_min_pageview_url_table;
CREATE TEMPORARY TABLE next_min_pageview_url_table
SELECT 
np.time_period,
np.website_session_id,
wp.pageview_url as next_pageview
FROM next_min_pageview_id_table np
LEFT JOIN website_pageviews wp ON np.next_min_pageview_id = wp.website_pageview_id;

SELECT * FROM next_min_pageview_url_table;

-- Step 4
SELECT 
time_period,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(DISTINCT CASE WHEN next_pageview IS NOT NULL THEN website_session_id ELSE NULL END) as w_next_page,
COUNT(DISTINCT CASE WHEN next_pageview IS NOT NULL THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT website_session_id) as pct_w_next_page,
COUNT(DISTINCT CASE WHEN next_pageview = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) as to_mrfuzzy,
COUNT(DISTINCT CASE WHEN next_pageview = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT website_session_id) as pct_to_mrfuzzy,
COUNT(DISTINCT CASE WHEN next_pageview = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) as to_lovebear,
COUNT(DISTINCT CASE WHEN next_pageview = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) / 
	COUNT(DISTINCT website_session_id) as pct_to_lovebear
FROM next_min_pageview_url_table
GROUP BY 1;

-- Building Product-Level Conversion Funnels

DROP TEMPORARY TABLE IF EXISTS product_type_table;
CREATE TEMPORARY TABLE product_type_table
SELECT website_session_id, website_pageview_id, pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');

SELECT * FROM product_type_table;

-- finding the right pageview_url to build the funnels
SELECT DISTINCT
wp.pageview_url
FROM product_type_table pt
LEFT JOIN website_pageviews wp ON pt.website_session_id = wp.website_session_id
AND wp.website_pageview_id > pt.website_pageview_id;

-- finding out next pages after product_seen
DROP TEMPORARY TABLE IF EXISTS page_level_table;
CREATE TEMPORARY TABLE page_level_table
SELECT pt.website_session_id, pt.pageview_url as product_seen, wp.pageview_url as next_page,
CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END as shipping_page,
CASE WHEN wp.pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END as billing_page,
CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM product_type_table pt
LEFT JOIN website_pageviews wp ON pt.website_session_id = wp.website_session_id
AND wp.website_pageview_id > pt.website_pageview_id
ORDER BY pt.website_session_id;

SELECT * FROM page_level_table;

DROP TEMPORARY TABLE IF EXISTS made_it_table;
CREATE TEMPORARY TABLE made_it_table
SELECT website_session_id,
product_seen,
MAX(cart_page) as cart_made_it,
MAX(shipping_page) as shipping_made_it,
MAX(billing_page) as billing_made_it,
MAX(thankyou_page) as thankyou_made_it
FROM
page_level_table
GROUP BY 1,2;

SELECT * FROM made_it_table;

SELECT product_seen,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) as to_shipping,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) as to_billing,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM made_it_table
GROUP BY product_seen;

SELECT 
product_seen,
to_cart/sessions as product_page_click_rt,
to_shipping/to_cart as cart_click_rt,
to_billing/to_shipping as shipping_click_rt,
to_thankyou/to_billing as billing_click_rt
FROM(
SELECT product_seen,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) as to_shipping,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) as to_billing,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM made_it_table
GROUP BY product_seen) as pageview_total;

-- Cross-Sell

DROP TEMPORARY TABLE IF EXISTS cart_next_id_table;
CREATE TEMPORARY TABLE cart_next_id_table
SELECT
time_period,
cart_table.website_session_id,
MIN(wp.website_pageview_id) as next_pageview_id
FROM(
SELECT
CASE 
WHEN created_at BETWEEN '2013-08-25' AND '2013-09-25' THEN 'A. Pre_Cross_Sell' 
WHEN created_at BETWEEN '2013-09-25' AND '2013-10-25' THEN 'B. Post_Cross_Sell' 
ELSE 'out of period'
END as time_period,
website_pageview_id, website_session_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
AND pageview_url = '/cart') as cart_table
LEFT JOIN website_pageviews wp ON cart_table.website_session_id = wp.website_session_id
AND wp.website_pageview_id > cart_table.website_pageview_id
GROUP BY 1,2;

DROP TEMPORARY TABLE IF EXISTS cart_next_url_table;
CREATE TEMPORARY TABLE cart_next_url_table
SELECT 
cart_next_id_table.time_period,
cart_next_id_table.website_session_id, 
-- cart_next_id_table.next_pageview_id, 
wp.pageview_url
FROM cart_next_id_table
LEFT JOIN website_pageviews wp ON cart_next_id_table.next_pageview_id = wp.website_pageview_id;

SELECT * FROM cart_next_url_table;

SELECT
ct.time_period,
COUNT(DISTINCT ct.website_session_id) as cart_sessions,
COUNT(CASE WHEN ct.pageview_url IS NOT NULL THEN ct.website_session_id ELSE NULL END) as clickthroughs,
COUNT(CASE WHEN ct.pageview_url IS NOT NULL THEN ct.website_session_id ELSE NULL END)/
	COUNT(DISTINCT ct.website_session_id) as cart_ctr,
SUM(ot.items_purchased)/COUNT(DISTINCT ot.order_id) as products_per_order,
SUM(ot.price_usd)/COUNT(DISTINCT ot.order_id) as aov,
SUM(ot.price_usd)/COUNT(DISTINCT ct.website_session_id) as revenue_per_session
FROM cart_next_url_table ct
LEFT JOIN orders ot ON ct.website_session_id = ot.website_session_id
GROUP BY 1;

-- Product Portfolio Expansion
SELECT 
time_period,
COUNT(DISTINCT order_id)/COUNT(DISTINCT sq.website_session_id) as session_to_order_conv_rate,
SUM(price_usd)/COUNT(DISTINCT order_id) as aov,
SUM(items_purchased)/COUNT(DISTINCT order_id) as products_per_order,
SUM(price_usd)/COUNT(DISTINCT sq.website_session_id) as revenue_per_cart_session
FROM
	(SELECT
	CASE 
	WHEN created_at BETWEEN '2013-11-12' AND '2013-12-12' THEN 'A. Pre_Birthday_Bear' 
	WHEN created_at BETWEEN '2013-12-12' AND '2014-01-12' THEN 'B. Post_Birthday_Bear' 
	ELSE 'out of period' 
	END as time_period,
	website_session_id
	FROM website_sessions
	WHERE created_at BETWEEN '2013-11-12' AND '2014-01-12') as sq
LEFT JOIN orders ON sq.website_session_id = orders.website_session_id
GROUP BY 1;

-- Product Refund Rates

SELECT DISTINCT product_id
FROM order_items
WHERE created_at < '2014-10-15';

SELECT COUNT(DISTINCT order_item_id)
FROM order_item_refunds
WHERE created_at < '2014-10-15';

SELECT 
YEAR(oi.created_at) as yr, 
MONTH(oi.created_at) as mo,
COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_item_id ELSE NULL END) as p1_orders,
-- COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oir.order_item_refund_id ELSE NULL END) as p1_refunds,
COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oir.order_item_refund_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_item_id ELSE NULL END) as p1_refund_rt,
COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_item_id ELSE NULL END) as p2_orders,
-- COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oir.order_item_refund_id ELSE NULL END) as p2_refunds,
COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oir.order_item_refund_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_item_id ELSE NULL END) as p2_refund_rt,
COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_item_id ELSE NULL END) as p3_orders,
-- COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oir.order_item_refund_id ELSE NULL END) as p3_refunds,
COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oir.order_item_refund_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_item_id ELSE NULL END) as p3_refund_rt,
COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oi.order_item_id ELSE NULL END) as p4_orders,
-- COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oir.order_item_refund_id ELSE NULL END) as p4_refunds
COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oir.order_item_refund_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oi.order_item_id ELSE NULL END) as p4_refund_rt
-- oi.order_item_id, oi.product_id, oir.order_item_refund_id
FROM order_items oi
LEFT JOIN order_item_refunds oir ON oi.order_item_id = oir.order_item_id
WHERE oi.created_at < '2014-10-15'
GROUP BY 1,2;
