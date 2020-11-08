# E-commerce Traffic and Website Analysis in MySQL
## Overview
Maven Fuzzy Factory is a virtual online retailer which has just launched their first product.
As an E-commerce Database Analyst, I used MySQL to explore the database to understand how customers access and interact with the site,
analyzed landing page performance and conversion with A/B testing, and used data to understand the impact of new product launches, with the goal of optimizing business’ marketing channel, website and product portfolio to help the business grow.

## Maven Fuzzy Factory Database Schema

<p align="center">
  <img src="/images/maven_fuzzy_factory_database.png" width="1000" />
</p>

These table contain e-commerce data about:
- Website Activity
- Products
- Orders and Refunds

Data source: [Advanced SQL + MySQL for Analytics & Business Intelligence](https://www.udemy.com/course/advanced-sql-mysql-for-analytics-business-intelligence/)

## Traffic Analysis
### Top Traffic Source Analysis
Traffic source analysis is about understanding where the customers are coming from and which channels are driving the highest quality traffic.
- Analyzing search data and shifting budget towards the engines, campaigns or keywords which driving the strongest conversion rates
- Comparing user behavior patterns across traffic sources to inform creative and messaging strategy
- Identifying opportunities to eliminate wasted spend or scale high-converting traffic

#### Tasks
1. Finding top traffic sources with highest volume of sessions.
2. Calculate traffic source session-to-order conversion rates for the decision either to dial up or dial down the search bids.
3. Trend Analysis of the volume of sessions after changing the bids.

-> [SQL Queries](Traffic_Source_Analysis.sql)

### Bid Optimization
Analyzing for bid optimization to about understanding the value of various segments of paid traffic in order to optimize marketing budget.
- Using conversion rate and revenue per click analyses to figure to how much should be spent per click to acquire customers
- Understanding how the website and products perform for various subsegments of traffic (i.e. mobile vs desktop) to optimize within channels
- Analyzing the impact that bid changes have on ranking in the auctions, and the volume of customers driven to the website

#### Tasks
1. Bid optimisation for paid traffic by calculating sessions-to-orders by device type.
2. Trending analysis by device type.

-> [SQL Queries](Bid_Optimization.sql)

## Website Performance Analysis
### Website content analysis
Website content analysis is about understanding which pages are seen the most by users, to identify where to focus on improving the business.
- Finding the most-viewed pages that customers view on the website
- Identifying the most common entry pages to the website

#### Tasks
1. Finding top website pages.
2. Finding top landing pages.

-> [SQL Queries](Top_Website_Pages_And_Entry_Pages.sql)

### Landing Page Performance and Testing
Landing page analysis and testing is about understanding the performance of the key landing pages and then testing to improve the results.
- Identifying top opportunities for landing pages - high volume pages with higher than expected bounce rates or low conversion rates
- Setting up A/B experiments on the live traffic to see if the bounce rates and conversion rates can be improved
- Analyzing test results and making recommendations on which version of landing pages should be used going forward

#### Tasks
1. Calculating bounce rate of the landing page.
The original landing page had a high bounce rate. We tested a new custom landing by setting up an A/B experiment to see if the new page does better.
2. Landing page tests: comparing the bounce rates of old and new landing page.
The new landing page was a success with lower bounce rate. Website manager rerouted all of the paid search traffic to the new landing page.
3. Landing page trend analysis: to confirm that the traffic was all routed as expected and to see the trend of the bounce rate after implementing the new landing page.

-> [SQL Queries](Landing_Page_Performance_and_Testing.sql)

### Conversion Funnel Analysis
Conversion funnel analysis is about understanding and optimize each step of user’s experience on their journey towards purchasing the products
- Identifying the most common paths customers take before purchasing the products
- Identifying how many of the users continue on to each next step in the conversion flow, and how many users abandon at each step
- Optimizing critical pain point where users are abandoning, so that we can convert more users and sell more products

#### Tasks
1. Building conversion funnels.
Shipping-to-billing click-through rate was pretty low. We tested an updated billing page that made the customers more comfortable entering their credit card info.
2. Analyzing conversion funnel tests: to see if new version of the billing page is doing much better job converting customers.

-> [SQL Queries](Conversion_Funnel_Analysis.sql)

## Channel Portfolio Optimization
Analyzing a portfolio of marketing channels by drawing insight from the data on how to bid efficiently and to maximize the effectiveness of marketing budget:
- Understanding which marking channels are driving the most sessions to orders (sales) through your website
- Understanding differences in user characteristics and conversion performance across marketing channels
- Optimizing bids and allocating marketing spend across a multi-channel portfolio to achieve maximum performance

#### Tasks
1. Analyzing channel portfolios: to find out which ads (utm_content) performs better, with better sessions-to-orders conversion rate.
2. Comparing channel characteristics (percentage of device type).
3. Cross channel bid optimisation (by device type): to know whether we should have the same bids for both search channels.
4. Analyzing channel portfolio trends (after bidding down): to see the impact of bid changes.
5. Direct, Organic and Brand-Driven Traffic Analysis: to see whether the free traffics are growing together with the paid brand traffic.

-> [SQL Queries](Channel_Portfolio_Management_Analysis.sql)

## Seasonality and Business Patterns Analysis
Analyzing business pattern is about generating insights to help maximize the efficiency and to anticipate future trends.
- Day-parting analysis to understand how much support staff we should have at different times of the day or days of the week
- Analyzing seasonality for better prepare for upcoming spikes and slowdowns in demand

#### Tasks
1. Seasonality: to find any seasonal trend that should be planned for next year, example more customer support and better inventory management during peak seasons.
2. Business Patterns: adding live chat support to improve customer experience (to see when is the peak hours during the day with the most average sessions).

-> [SQL Queries](Seasonality_Analysis_and_Business_Pattern.sql)

## Product Sales Analysis
Analyzing product sales can help you understand how each product is contributing to your business and how new product launches are impacting your overall portfolio.
- Analyzing sales and revenues by product
- Monitoring the impact of adding new product to product portfolio
- Watching product sales trends to understand the overall health of the business

#### Tasks
1. Product-Level Sales: Monthly trends analysis will serve a great baseline data so that we can see how the revenue and margin evolve as we roll out a new product.
2. Product Launches: To see the change in conversion rate and revenue over the months after new product launched.
3. Product-Level Website Pathing:
  - to analyse the impact on customer website behavior.
  - to understand how many customer are hitting the product’s page and then what they do next on the website, either the customer will just abandon at the product’s page or will click to one the products.
  - to analyse clickthrough rate and next page performance.
4. Building Product-Level Conversion Funnels: for each product, the full conversion funnel from each product page to a sale event. Comparison between conversion funnels in order to understand which of the products converts better and if there are specific drop off points for specific products.
5. Cross-Selling Products:
  - to understand which products users are most likely to purchase together, and offering smart product recommendations.
  - to calculate the cart clickthrough rate before and after implementing the cross sell product in the cart page and to see whether the customer is annoyed by the smart product recommendation.
6. Product Portfolio Expansion: Pre-post analysis comparing the month before vs. the month after the cross sell product launch to see the performance metrics like session-to-order conversion rate, aov, product per order and revenue per session.
7. Product Refund Rates (Total number of refunds / total number of product sold): to measure quality issues.

-> [SQL Queries](Product_Sales_Analysis.sql)

## User Repeat Behavior Analysis
Analyzing the repeat visits helps us understand the overall user behavior and it can help us identify some of our most valuable customers.
- Analyzing repeat activity to see how often customers are coming back to visit the site
- Understanding which channels they use when they come back, and whether or not we are paying for them again through paid channels
- Using the repeat visit activity to build a better understanding of the value of a customer in order to better optimize marketing channels

#### Tasks
1. Identifying repeat visitors.
2. Analysing time to repeat: how many days is the customer coming back again to visit again.
3. Analysing repeat channel behaviour (mostly through organic search, direct type-in or paid brand channel).
4. Analysing new and repeat conversion rates as well as revenue per session.

-> [SQL Queries](User_Repeat_Behavior_Analysis.sql)
