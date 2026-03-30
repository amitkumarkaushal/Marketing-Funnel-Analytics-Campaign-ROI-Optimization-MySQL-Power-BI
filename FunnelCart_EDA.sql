-- =============================================
-- Exploratory Data Analysis (EDA)
-- =============================================

-- 1. How much budget is allocated by marketing channel?
-- Goal: Identify which channels consume most spend.

select 
	ch.channel_id, 
    ch.channel_name, 
    count(campaign_id) as total_campaigns, 
    sum(budget) as Highest_Budget
from 
	campaign ca
join 
	channels ch on ca.channel_id = ch.channel_id
group by 
	ch.channel_id, ch.channel_name
order by 
	Highest_Budget desc;

-- 2. Which campaigns generated the highest funnel traffic?
-- Goal: Determine whether high-spend campaigns actually generate traffic.

SELECT 
    c.campaign_id,
    c.campaign_name,
    ch.channel_name,
    COUNT(DISTINCT fe.customer_id) AS unique_customers,
    COUNT(fe.event_id) AS total_funnel_events,
    RANK() OVER(ORDER BY COUNT(DISTINCT fe.customer_id) DESC) AS traffic_rank
FROM campaign c
JOIN funnel_events fe
    ON c.campaign_id = fe.campaign_id
JOIN channels ch
    ON c.channel_id = ch.channel_id
GROUP BY 
    c.campaign_id,
    c.campaign_name,
    ch.channel_name;
    
-- 3. Which campaigns spent the most budget but acquired the fewest customers?
-- Goal: Find the campaigns that are consuming significant spend without effectively driving customer acquisition, contributing to the negative marketing ROI.

WITH campaign_customer_acquisition AS (
    SELECT 
        c.campaign_id,
        c.campaign_name,
        c.budget,
        COUNT(DISTINCT cu.customer_id) AS customers_acquired
    FROM campaign c
    LEFT JOIN funnel_events fe 
        ON c.campaign_id = fe.campaign_id
    LEFT JOIN customers cu 
        ON fe.customer_id = cu.customer_id
    GROUP BY c.campaign_id, c.campaign_name, c.budget
)

SELECT 
    campaign_id,
    campaign_name,
    budget,
    customers_acquired,
    RANK() OVER (ORDER BY budget DESC) AS budget_rank,
    RANK() OVER (ORDER BY customers_acquired ASC) AS low_acquisition_rank
FROM campaign_customer_acquisition
ORDER BY budget DESC, customers_acquired ASC;

-- 4. Which marketing channels acquire the most customers?

SELECT 
    ch.channel_name,
    COUNT(c.customer_id) AS total_customers_acquired,
    RANK() OVER (ORDER BY COUNT(c.customer_id) DESC) AS acquisition_rank
FROM customers c
JOIN channels ch
    ON c.acquisition_channel_id = ch.channel_id
GROUP BY ch.channel_name
ORDER BY total_customers_acquired DESC;

-- 5. What is the customer acquisition trend over time?
-- Insight: Customer acquisition shows monthly fluctuations rather than consistent growth, suggesting campaigns are failing to sustain a steady inflow of new users.

WITH monthly_acquisition AS (
    SELECT 
        DATE_FORMAT(signup_date, '%m-%Y') AS signup_month,
        COUNT(customer_id) AS customers_acquired
    FROM customers
    GROUP BY DATE_FORMAT(signup_date, '%m-%Y')
)
SELECT 
    signup_month,
    customers_acquired,
    LAG(customers_acquired) OVER (ORDER BY signup_month) AS prev_month_acquisition,
    customers_acquired - LAG(customers_acquired) OVER (ORDER BY signup_month) AS mom_change
FROM monthly_acquisition
ORDER BY signup_month;

-- 6. Which cities or regions generate the highest number of acquired users?

SELECT 
    city,
    state,
    country,
    COUNT(customer_id) AS total_acquired_users,
    RANK() OVER (ORDER BY COUNT(customer_id) DESC) AS city_rank
FROM customers
GROUP BY city, state, country
ORDER BY total_acquired_users DESC;

-- 7. What is the total number of users at each funnel stage?

-- Total User Base
SELECT COUNT(DISTINCT customer_id)
FROM customers;

-- Users who performed a funnel action
SELECT 
    funnel_stage,
    COUNT(DISTINCT fe.customer_id) AS total_users
FROM customers c
JOIN funnel_events fe on c.customer_id = fe.customer_id
GROUP BY funnel_stage
ORDER BY total_users DESC;

-- 8. What is the conversion rate between funnel stages?

WITH stage_users AS (
    SELECT 
        funnel_stage,
        COUNT(DISTINCT customer_id) AS users
    FROM funnel_events
    GROUP BY funnel_stage
)

SELECT 
    funnel_stage,
    users AS current_stage_users,
    LAG(users) OVER (ORDER BY 
        CASE funnel_stage
            WHEN 'Awareness' THEN 1
            WHEN 'Interest' THEN 2
            WHEN 'Consideration' THEN 3
            WHEN 'Intent' THEN 4
            WHEN 'Purchase' THEN 5
        END
    ) AS previous_stage_users,
    
    ROUND(
        users / LAG(users) OVER (ORDER BY 
            CASE funnel_stage
                WHEN 'Awareness' THEN 1
                WHEN 'Interest' THEN 2
				WHEN 'Consideration' THEN 3
				WHEN 'Intent' THEN 4
				WHEN 'Purchase' THEN 5
            END
        ) * 100, 2
    ) AS stage_conversion_rate_pct
    
 FROM stage_users;