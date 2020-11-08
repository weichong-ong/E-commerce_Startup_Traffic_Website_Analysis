USE mavenfuzzyfactory;

# Top website page
SELECT pageview_url, COUNT(DISTINCT website_pageview_id) as sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;

# Top entry page
# Step 1: find the first pageview for each session
DROP TEMPORARY TABLE IF EXISTS first_pageview;
CREATE TEMPORARY TABLE first_pageview
SELECT 
website_session_id,
MIN(website_pageview_id) as first_pg_view
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT * FROM first_pageview;

# Step 2: find the url the customer saw that first pageview
SELECT 
wp.pageview_url AS landing_page_url, 
COUNT(DISTINCT fp.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview fp
LEFT JOIN website_pageviews wp ON fp.first_pg_view = wp.website_pageview_id
GROUP BY wp.pageview_url;

