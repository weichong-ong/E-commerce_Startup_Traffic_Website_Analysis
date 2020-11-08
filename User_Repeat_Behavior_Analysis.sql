-- Identifying repeat visitors
SELECT repeat_sessions,
COUNT(DISTINCT CASE WHEN total_sessions <> repeat_sessions THEN user_id ELSE NULL END) as number_of_user
FROM
(SELECT user_id,
COUNT(DISTINCT website_session_id) as total_sessions,
SUM(is_repeat_session) as repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
GROUP BY 1) as tt
GROUP BY 1;

-- Instructor's solution
DROP TEMPORARY TABLE IF EXISTS new_user_table;
CREATE TEMPORARY TABLE new_user_table
SELECT
new_user.user_id as user,
COUNT(DISTINCT ws.website_session_id) as repeat_sessions
-- same result: SUM(ws.is_repeat_session) but output NULL instead of 0
FROM
(SELECT 
user_id, -- find out the new users who first visit the website
website_session_id
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
AND is_repeat_session = 0) new_user
LEFT JOIN website_sessions ws ON new_user.user_id = ws.user_id
AND ws.is_repeat_session = 1
AND ws.created_at BETWEEN '2014-01-01' AND '2014-11-01'
GROUP BY 1;

-- SELECT * FROM new_user_table;

SELECT repeat_sessions,
COUNT(DISTINCT user) as number_of_user
FROM new_user_table
GROUP BY 1;


-- Analysing Time to repeat
DROP TEMPORARY TABLE IF EXISTS repeat_new_user;
CREATE TEMPORARY TABLE repeat_new_user
SELECT 
new_user.user_id as repeat_new_user_id, 
new_user.website_session_id as first_session_id,
new_user.created_at as first_session_date,
MIN(ws.website_session_id) as second_session_id,
MIN(ws.created_at) as second_session_date
FROM
(SELECT 
user_id, -- find out the new users who first visit the website
website_session_id,
created_at
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
AND is_repeat_session = 0) new_user
LEFT JOIN website_sessions ws ON new_user.user_id = ws.user_id
AND ws.is_repeat_session = 1
AND ws.created_at BETWEEN '2014-01-01' AND '2014-11-03'
WHERE ws.is_repeat_session = 1
GROUP BY 1,2,3;

SELECT * FROM repeat_new_user;

SELECT 
AVG(DATEDIFF(second_session_date, first_session_date)) as avg_days_first_to_second,
MIN(DATEDIFF(second_session_date, first_session_date)) as min_days_first_to_second,
MAX(DATEDIFF(second_session_date, first_session_date)) as max_days_first_to_second
FROM repeat_new_user;

-- Analysing repeat channel behaviour

SELECT 
CASE 
	WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
	WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
    WHEN utm_source IS NOT NULL AND utm_campaign = 'brand' THEN 'paid_brand'
    WHEN utm_source IS NOT NULL AND utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_source = 'socialbook' THEN 'paid_social'
    ELSE 'others'
END as channel_group,
COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) as new_sessions,
COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) as repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1
ORDER BY 3 DESC;

-- Analysing new and repeat conversion rates

SELECT
ws.is_repeat_session,
COUNT(DISTINCT ws.website_session_id) as sessions,
COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as conv_rt,
SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) as revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1;
