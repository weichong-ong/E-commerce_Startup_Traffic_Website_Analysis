-- Analyzing Channel Portfolio 
SELECT 
MIN(DATE(created_at)) as week_start_date, 
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) as gsearch_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) as bsearch_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-29'
AND utm_campaign = 'nonbrand' 
GROUP BY YEARWEEK(created_at);


-- Comparing Channel Characteristics
SELECT utm_source,
COUNT(DISTINCT website_session_id) as sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) as mobile_sessions, 
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) as pct_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
AND utm_campaign = 'nonbrand' 
GROUP BY utm_source;

-- Cross Channel Bid Optimazation
SELECT ws.device_type, ws.utm_source,
COUNT(DISTINCT ws.website_session_id) as sessions,
COUNT(DISTINCT o.order_id) as orders,
COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) as conv_rate
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-08-22' AND '2012-09-18'
AND ws.utm_campaign = 'nonbrand' 
GROUP BY 1, 2;

-- Analysing Channel Portfolio Trends 
SELECT 
MIN(DATE(created_at)) as week_start_date, 
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) as gsearch_dtop_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) as bsearch_dtop_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) as b_pct_of_g_dtop,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) as gsearch_mob_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) as bsearch_mob_sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) as b_pct_of_g_mob
FROM website_sessions
WHERE created_at BETWEEN '2012-11-04' AND '2012-12-02'
AND utm_campaign = 'nonbrand' 
GROUP BY YEARWEEK(created_at);

-- Analysing Free Channels (Direct Type-In and Organic Channel)
SELECT 
YEAR(created_at) as yr,
MONTH(created_at) as mo,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) as nonbrand,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) as brand,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) as brand_pct_of_nonbrand,
COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) as direct,
COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) as direct_pct_of_nonbrand,
COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id ELSE NULL END) as organic,
COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id ELSE NULL END) /
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) as organic_pct_of_nonbrand
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY 1,2;
