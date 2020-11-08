USE mavenfuzzyfactory;

# Building_conversion_funnels
DROP TEMPORARY TABLE IF EXISTS page_madeit_table;
CREATE TEMPORARY TABLE page_madeit_table
SELECT website_session_id,
MAX(product_page) as product_made_it,
MAX(mr_fuzzy_page) as mr_fuzzy_made_it,
MAX(cart_page) as cart_made_it,
MAX(shipping_page) as shipping_made_it,
MAX(billing_page) as billing_made_it,
MAX(thankyou_page) as thankyou_made_it
FROM
(SELECT ws.website_session_id, wp.pageview_url, wp.created_at,
CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END as product_page,
CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END as mr_fuzzy_page,
CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END as cart_page,
CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END as shipping_page,
CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END as billing_page,
CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END as thankyou_page
FROM website_pageviews wp
LEFT JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at > '2012-08-05' AND ws.created_at < '2012-09-05'
#AND wp.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
ORDER BY
ws.website_session_id,
wp.created_at) as page_level
GROUP BY website_session_id
ORDER BY website_session_id;

SELECT * FROM page_madeit_table;

SELECT COUNT(DISTINCT website_session_id) as sessions,
COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) as to_products,
COUNT(CASE WHEN mr_fuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as to_mr_fuzzy,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) as to_shipping,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) as to_billing,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM page_madeit_table;

SELECT
to_products/sessions as lander_click_rt,
to_mr_fuzzy/to_products product_click_rt,
to_cart/to_mr_fuzzy as mr_fuzzy_click_rt,
to_shipping/to_cart as cart_click_rt,
to_billing/to_shipping as shipping_click_rt,
to_thankyou/to_billing as billing_click_rt
FROM(
SELECT COUNT(DISTINCT website_session_id) as sessions,
COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) as to_products,
COUNT(CASE WHEN mr_fuzzy_made_it = 1 THEN website_session_id ELSE NULL END) as to_mr_fuzzy,
COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) as to_cart,
COUNT(CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) as to_shipping,
COUNT(CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) as to_billing,
COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) as to_thankyou
FROM page_madeit_table) as pageview_total;

/*
SELECT *
FROM website_pageviews wp
LEFT JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at > '2012-08-05' AND ws.created_at < '2012-09-05'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
AND ws.website_session_id = 18241;
*/


# Conversion_Funnel_Tests_Analysis
SELECT MIN(created_at) as first_created_at,
MIN(website_pageview_id) as first_pageview_id
FROM website_pageviews
WHERE created_at < '2012-11-10' AND pageview_url = '/billing-2';

SELECT wp.pageview_url,
COUNT(DISTINCT wp.website_session_id) as sessions,
COUNT(DISTINCT orders.order_id) as orders,
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT wp.website_session_id) as billing_to_order_rt
FROM website_pageviews wp
LEFT JOIN orders ON wp.website_session_id = orders.website_session_id
WHERE wp.created_at > '2012-09-10' AND wp.created_at < '2012-11-10'
AND wp.website_pageview_id >= 53550
AND wp.pageview_url IN ('/billing-2','/billing')
GROUP BY wp.pageview_url;

SELECT * FROM orders;
