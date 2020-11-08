-- Analyzing Seasonality
SELECT 
YEAR(ws.created_at) as yr, 
MONTH(ws.created_at) as mo,
COUNT(DISTINCT ws.website_session_id) as sessions,
COUNT(DISTINCT o.order_id) as orders
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2013-01-01'
GROUP BY 1, 2;

SELECT 
MIN(DATE(ws.created_at)) as week_start_date, 
COUNT(DISTINCT ws.website_session_id) as sessions,
COUNT(DISTINCT o.order_id) as orders
FROM website_sessions ws
LEFT JOIN orders o ON ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2013-01-01'
GROUP BY YEARWEEK(ws.created_at);

-- Business Pattern
SELECT 
hr, 
AVG(website_sessions),
ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) as Monday,
ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) as Tuesday,
ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) as Wedday,
ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) as Thursday,
ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) as Friday,
ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) as Saturday,
ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) as Sunday
FROM
	(SELECT 
    DATE(created_at) as created_date,
	WEEKDAY(created_at) as wkday,
    HOUR(created_at) as hr,
	COUNT(DISTINCT website_session_id) as website_sessions
	FROM website_sessions ws
	WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
	GROUP BY 1,2,3) as daily_hourly_sessions
GROUP BY 1;

SELECT 
    DATE(created_at) as created_date,
	WEEKDAY(created_at) as wkday,
    HOUR(created_at) as hr,
	COUNT(DISTINCT website_session_id) as website_sessions
	FROM website_sessions ws
	WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
	GROUP BY 1,2,3;
/*
CASE
	WHEN WEEKDAY(created_at) = 0 THEN 'Monday'
    ELSE 'other day'
    END AS