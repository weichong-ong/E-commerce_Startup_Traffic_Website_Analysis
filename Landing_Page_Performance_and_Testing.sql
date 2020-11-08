USE mavenfuzzyfactory;

# Bounce rate of landing page
# Step 1: find the first pageview_id for relevant session
DROP TEMPORARY TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview
SELECT
website_session_id,
MIN(website_pageview_id) as first_pageview_id
FROM website_pageviews wp
WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

SELECT * from first_pageview;

# Step 2: identify the landing page of each session
DROP TEMPORARY TABLE IF EXISTS session_w_landing_page;
CREATE TEMPORARY TABLE session_w_landing_page
SELECT fp.website_session_id, wp.pageview_url as landing_page
FROM first_pageview fp
LEFT JOIN website_pageviews wp ON fp.first_pageview_id = wp.website_pageview_id;

SELECT * from session_w_landing_page;

# Step 3: counting pageviews for each session, to identify bounces
DROP TEMPORARY TABLE IF EXISTS bounce_sessions_only;
CREATE TEMPORARY TABLE bounce_sessions_only
SELECT
sl.website_session_id, sl.landing_page,
COUNT(wp.website_pageview_id) as count_of_pages_viewed
FROM session_w_landing_page sl
LEFT JOIN website_pageviews wp ON sl.website_session_id = wp.website_session_id
GROUP BY sl.website_session_id, sl.landing_page
HAVING count_of_pages_viewed = 1;

SELECT * from bounce_sessions_only;

/*
SELECT *
FROM session_w_landing_page sl
LEFT JOIN bounce_sessions_only bs ON sl.website_session_id = bs.website_session_id
ORDER BY sl.website_session_id;
*/

# Step 4: summarizing total sessions and bounced sessions, by landing page
SELECT sl.landing_page,
COUNT(DISTINCT sl.website_session_id) as number_of_sessions,
COUNT(DISTINCT bs.website_session_id) as number_of_bounced_sessions,
COUNT(DISTINCT bs.website_session_id)/COUNT(DISTINCT sl.website_session_id)*100 as bounce_rate
FROM session_w_landing_page sl
LEFT JOIN bounce_sessions_only bs ON sl.website_session_id = bs.website_session_id
GROUP BY sl.landing_page;

# Landing Page Tests
# Step 0: find the first instance of /lander-1 to set analysis timeframe
SELECT
MIN(created_at) as first_created_at,
MIN(website_pageview_id) as first_pageview_id
FROM website_pageviews
WHERE created_at < '2012-07-28' AND pageview_url = '/lander-1';

# Step 1: find the first pageview_id for relevant session only for gsearch and nonbrand
DROP TEMPORARY TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview
SELECT
wp.website_session_id,
MIN(wp.website_pageview_id) as first_pageview_id
FROM website_pageviews wp
INNER JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
WHERE wp.created_at < '2012-07-28'
AND wp.website_pageview_id >= 23504
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;

SELECT * from first_pageview;

# Step 2: identify the landing page of each session
DROP TEMPORARY TABLE IF EXISTS session_w_landing_page;
CREATE TEMPORARY TABLE session_w_landing_page
SELECT fp.website_session_id, wp.pageview_url as landing_page
FROM first_pageview fp
LEFT JOIN website_pageviews wp ON fp.first_pageview_id = wp.website_pageview_id
WHERE wp.pageview_url = '/lander-1' OR pageview_url = '/home';
# WHERE wp.pageview_url in ('/lander-1','/home');

SELECT * from session_w_landing_page;

# Step 3: counting pageviews for each session, to identify bounces
DROP TEMPORARY TABLE IF EXISTS bounce_sessions_only;
CREATE TEMPORARY TABLE bounce_sessions_only
SELECT
sl.website_session_id, sl.landing_page,
COUNT(wp.website_pageview_id) as count_of_pages_viewed
FROM session_w_landing_page sl
LEFT JOIN website_pageviews wp ON sl.website_session_id = wp.website_session_id
GROUP BY sl.website_session_id, sl.landing_page
HAVING count_of_pages_viewed = 1;

SELECT * from bounce_sessions_only;

/*
SELECT sl.landing_page, sl.website_session_id, bs.website_session_id
FROM session_w_landing_page sl
LEFT JOIN bounce_sessions_only bs ON sl.website_session_id = bs.website_session_id
ORDER BY sl.website_session_id;
*/

# Step 4: summarizing total sessions and bounced sessions, by landing page
SELECT sl.landing_page,
COUNT(DISTINCT sl.website_session_id) as number_of_sessions,
COUNT(DISTINCT bs.website_session_id) as number_of_bounced_sessions,
COUNT(DISTINCT bs.website_session_id)/COUNT(DISTINCT sl.website_session_id)*100 as bounce_rate
FROM session_w_landing_page sl
LEFT JOIN bounce_sessions_only bs ON sl.website_session_id = bs.website_session_id
GROUP BY sl.landing_page;

# Landing Page Trend Analysis
# Step 1: find the first pageview_id and count pageview for relevant session only for gsearch and nonbrand
DROP TEMPORARY TABLE IF EXISTS sessions_first_pageview_count;
CREATE TEMPORARY TABLE sessions_first_pageview_count
SELECT
ws.website_session_id,
MIN(wp.website_pageview_id) as first_pageview_id,
COUNT(wp.website_pageview_id) as count_of_pages_viewed
FROM website_sessions ws
LEFT JOIN website_pageviews wp ON wp.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-08-31'
AND ws.created_at > '2012-06-01'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'
GROUP BY ws.website_session_id;

/*
SELECT * from website_sessions
WHERE website_session_id = 9302;
SELECT * from website_pageviews
WHERE website_session_id = 9302;
*/

SELECT * from sessions_first_pageview_count;

# Step 2: identify the landing page and created_at of each session
DROP TEMPORARY TABLE IF EXISTS session_w_counts_landing_page_created_at;
CREATE TEMPORARY TABLE session_w_counts_landing_page_created_at
SELECT fp.website_session_id, fp.first_pageview_id, fp.count_of_pages_viewed,
wp.created_at, wp.pageview_url as landing_page
FROM sessions_first_pageview_count fp
LEFT JOIN website_pageviews wp ON fp.first_pageview_id = wp.website_pageview_id;

SELECT * from session_w_counts_landing_page_created_at;

# Step 3:
SELECT
-- YEARWEEK(created_at),
MIN(DATE(created_at)) as week_start_date,
-- COUNT(DISTINCT website_session_id) as total_sessions,
-- COUNT(DISTINCT CASE WHEN count_of_pages_viewed = 1 THEN website_session_id ELSE NULL END) as bounced_sessions,
COUNT(DISTINCT CASE WHEN count_of_pages_viewed = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as bounce_rate,
COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) as home_sessions,
COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) as lander_sessions
FROM session_w_counts_landing_page_created_at
#GROUP BY YEAR(created_at), WEEK(created_at);
GROUP BY YEARWEEK(created_at);
