USE mavenfuzzyfactory;

# Finding Top Traffic Source
SELECT utm_source, utm_campaign, http_referer, count(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

# Traffic Source Conversion Rate
SELECT count(DISTINCT ws.website_session_id) as number_of_sessions, count(DISTINCT o.order_id) as number_of_orders,
count(DISTINCT o.order_id)/count(DISTINCT ws.website_session_id)*100 as conversion_rate_percent
FROM website_sessions ws
LEFT JOIN
orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-04-12' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
-- GROUP BY ws.utm_source, ws.utm_campaign, ws.http_referer
ORDER BY number_of_sessions DESC;

# Traffic Source Trending
SELECT MIN(date(created_at)) as week_start_date, COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
WHERE created_at < '2012-05-12' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at);

# Traffic Source Bid Optimization
SELECT ws.device_type, COUNT(DISTINCT ws.website_session_id) as number_of_sessions, COUNT(DISTINCT o.order_id) as number_of_orders,
count(DISTINCT o.order_id)/count(DISTINCT ws.website_session_id)*100 as conversion_rate_percent
FROM website_sessions ws
LEFT JOIN
orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-05-11' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY 1;

# Trending w/ Granular Segments
SELECT
MIN(date(ws.created_at)) as week_start_date,
COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) as desktop_sessions,
COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) as mobile_sessions
FROM website_sessions ws
LEFT JOIN
orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at > '2012-04-15' AND ws.created_at < '2012-06-09' AND utm_source = 'gsearch' AND utm_campaign = 'nonbrand'
GROUP BY YEAR(ws.created_at), WEEK(ws.created_at);
