# =========================================
 # SaaS Revenue & Churn Analysis
# =========================================

# Project: CloudTask Pro (B2B SaaS)
# Objective: Analyze churn, revenue trends, and customer behavior to identify retention risks and growth opportunities.

# =========================
# DATA CLEANING
# =========================

-- Remove duplicates

SELECT * 
FROM subscriptions_cl;


WITH Duplicate_CTE AS(
	SELECT 
		*,
        ROW_NUMBER() OVER(PARTITION BY 
			customer_id, plan, billing_cycle, industry, company_size, seats, monthly_revenue, acquisition_channel, region, signup_date, 
			churned, churn_date, churn_reason, support_tickets_12mo, nps_score, feature_usage_pct, upgraded)
            AS rn
	FROM subscriptions_cl
)
SELECT * 
FROM Duplicate_CTE
WHERE rn > 1;

-- There are no duplicates in the subscriptions dataset 

# Fix company size & region

UPDATE subscriptions_cl
SET company_size = '11-50' 
WHERE company_size = 'Nov-50';

UPDATE subscriptions_cl
SET company_size = '01-10' 
WHERE company_size = '01-Oct';

# Cleaned Region
UPDATE subscriptions_cl
SET region = 'Asia' 
WHERE region = 'Asia Pacific';

UPDATE subscriptions_cl
SET region = 'South America' 
WHERE region = 'Latin America';

SELECT *
FROM subscriptions_cl;

SELECT*
FROM monthly_revenue_cl;

#=========================
# CHURN ANALYSIS
#=========================

# Overall Churn Rate

SELECT 
    ROUND(
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(customer_id), 
    2) AS overall_churn_rate_pct
FROM subscriptions_cl;

# Churn by Plan & Company Size
 
WITH churn_customer AS(
	SELECT
		plan,
		company_size,
		COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscriptions_cl
    GROUP BY plan, company_size
 )
 SELECT
	plan,
    company_size,
	CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM churn_customer
ORDER BY churned_rate DESC;

# Churn by Billing Cycle
 
SELECT
	billing_cycle,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM(
	SELECT 	
		billing_cycle,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscriptions_cl
    GROUP BY billing_cycle
)t
ORDER BY churned_rate;

# Churn by Acquisition Channel
 
SELECT
	acquisition_channel,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM(
	SELECT 	
		acquisition_channel,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscriptions_cl
    GROUP BY acquisition_channel
)t
ORDER BY churned_rate;

# Churn by Region
 
SELECT
	region,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM (
	SELECT
		region,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscriptions_cl
    GROUP BY region
)t
ORDER BY churned_rate;


-- 2. Monthly churn rate trend over the past 4 years

SELECT month,
	monthly_churn_rate_pct
FROM monthly_revenue_cl
ORDER BY month;
	
-- 3. Whether Churn improving or worsening
-- Comparison of the first month and last month churn

WITH churn_trend as(
SELECT 
	month,
	monthly_churn_rate_pct,
	ROW_NUMBER() OVER (order by month) as rn_start,
	ROW_NUMBER() OVER(order by month desc) as rn_end
from monthly_revenue_cl
)
select 
	Max(case when rn_start = 1 then monthly_churn_rate_pct end) as first_month_churn,
	max(case when rn_end = 1 then monthly_churn_rate_pct end) as end_month_churn
from churn_trend;


-- The overall churn rate was 52.17%. Monthly churn averaged 4.52% over the four-year period.
-- Churn moved from 0% in the first month to 1.42% in the latest month, 
-- indicating that customer retention has improved/worsened over time. 
-- This trend suggests the company's retention efforts are becoming more/less effective.

-- Change_in_churn_rate is > 0 
-- then, churn is woresning because the monthly churn rate is increased over time. 


-- # Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? 

-- The Starter plan has the highest churn rate at 63.3%, 
-- suggesting that lower-tier customers are more likely to discontinue their subscriptions. 
-- Enterprise customers exhibit the strongest retention, indicating higher perceived value and greater product dependency.

-- # Does billing cycle (monthly vs. annual) significantly impact retention?

-- Customers on monthly subscriptions churn at a substantially higher rate than annual subscribers. 
-- Annual contracts appear to improve retention by increasing customer commitment and reducing opportunities to cancel.

# ========================
# CHURN REASON
# ======================== 

 # Top 3 Reasons by plan/company_size

 SELECT 
    plan,
    churn_reason,
    COUNT(*) AS total_churn
FROM subscriptions_cl
WHERE churned = 'Yes'
GROUP BY plan, churn_reason
ORDER BY total_churn DESC
LIMIT 3;

-- # What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size?

with churn_reason_rank as (
select plan,
	churn_reason,
	count(*) as churned_customers,
	row_number() over(partition by plan order by count(*) desc) as rnk
from subscriptions_cl
where churned = 'Yes'
group by plan, churn_reason
)
Select plan, 
	churn_reason,
	churned_customers
from churn_reason_rank
where rnk <= 3
order by plan, churned_customers desc;

-- Lower-tier customers primarily churn due to pricing concerns, 
-- while higher-tier customers tend to leave because of missing functionality or service-related issues.

-- # Do churn reason differ form company size

with churn_reason_rank as (
select company_size,
	churn_reason,
	count(*) as churned_customers,
	row_number() over(partition by company_size order by count(*) desc) as rnk
from subscriptions_cl
where churned = 'Yes'
group by company_size, churn_reason
)
Select company_size, 
	churn_reason,
	churned_customers
from churn_reason_rank
where rnk <= 3
order by company_size, churned_customers desc;

-- Smaller businesses are more price-sensitive, 
-- whereas larger organizations are more likely to churn because of product limitations and support expectations.

-- # which churn reason is costing the company the most revenue?

select churn_reason,
	count(*) as churned_customers,
	round(sum(monthly_revenue)::numeric,2) as lost_mrr
from subscriptions_cl
where churned = 'Yes'
group by churn_reason
order by lost_mrr desc;

-- Althrough " Price " is the most comman churn reason, " Missing Features " results in the 
-- highest revenue loss because it affects higher-paying customers.

#=========================
 # REVENUE ANALYSIS
#=========================

# Monthly MRR trend
 
WITH prev_month_mrr AS(
	SELECT
		month_rev,
        total_mrr,
        COALESCE(
			LAG(total_mrr) OVER(ORDER BY month_rev), total_mrr) AS prev_mrr
	FROM monthly_revenue_cl
)
	SELECT
		month_rev,
        total_mrr,
        prev_mrr,
		(total_mrr - prev_mrr) AS net_mrr_change,
		CONCAT(ROUND( 
			(total_mrr - prev_mrr) / prev_mrr * 100, 2 
		), '%') AS mrr_change_rate
	FROM prev_month_mrr
    ORDER BY month_rev DESC;
    
#=========================
 # UNIT ECONOMICS
#=========================

# CLV vs CAC

WITH churn_rate AS(
	SELECT
		s.plan,
        ROUND(AVG(s.monthly_revenue), 2) AS avg_rev,
		ROUND(SUM(CASE WHEN s.churned = 'Yes' THEN 1 ELSE 0 END) * 1.0 / 
				COUNT(s.customer_id), 4) AS churn_rate
	FROM subscriptions s
	GROUP BY s.plan
),
avg_cac AS(
SELECT
	AVG(m.customer_acquisition_cost) AS avg_cac
FROM monthly_revenue m
)
SELECT
	c.plan,
	c.avg_rev,
	ROUND(c.churn_rate, 2) AS churn_rate,
	ROUND((1.0 / c.churn_rate), 2) AS Lifespan,
    ROUND((c.avg_rev * (1.0 / c.churn_rate)), 2) AS CLV,
    ROUND(a.avg_cac, 2) AS avg_cac,
    ROUND((c.avg_rev * (1.0 / c.churn_rate)) / a.avg_cac, 2) AS clv_cac_ratio
FROM churn_rate c
CROSS JOIN avg_cac a
ORDER BY c.plan;

#ALTERNATIVE/OR

-- # Calculate the average Customer Lifetime Value (CLV) by plan. 
-- Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable?


-- Step 1. Calculate the average customerlife value 

-- Churn rate by plan 

with plan_churn as (
	select 
		plan,
		count(*) as total_customers,
		count(case when churned = 'Yes' then 1 end) as churned_customers,
		round(count(case when churned = 'Yes' then 1 end)*1.0/count(*)::numeric,2) as churn_rate
from subscriptions_cl
group by plan
)
select *
from plan_churn;

-- Estimate CLV by plan

with plan_metrics as (
	select 
		plan,
		avg(monthly_revenue) as Arpu,
		count(case when churned = 'Yes' then 1 end)*1.0/count(*) as churn_rate
from subscriptions_cl
group by plan
)
select 
	plan,
		round(Arpu::numeric,2) as Arpu,
		round(churn_rate*100,2) as churn_rate_pct,
		round((Arpu/nullif(churn_rate,0))::numeric,2) as estimate_clv
from plan_metrics
order by estimate_clv desc;
		
-- Step 3: Calculate Average CAC

select 
	round(avg(customer_acquisition_cost)::numeric,2) as avg_cac
from monthly_revenue_cl

-- Step 4: Compare CLV VS CAC

with plan_metrics as (
	select 
		plan,
		avg(monthly_revenue) as Arpu,
		count(case when churned = 'Yes' then 1 end)*1.0/count(*) as churn_rate
from subscriptions_cl
group by plan
),
cac as (
	select 
	round(avg(customer_acquisition_cost)::numeric,2) as avg_cac
from monthly_revenue_cl
)

select
	p.plan,
    ROUND((p.arpu / NULLIF(p.churn_rate,0))::numeric,2) AS clv,
    ROUND(c.avg_cac::numeric,2) AS cac,
    ROUND(
        ((p.arpu / NULLIF(p.churn_rate,0))
        / c.avg_cac)::numeric,
        2
    ) AS clv_cac_ratio
FROM plan_metrics p
CROSS JOIN cac c
ORDER BY clv_cac_ratio DESC;

-- Enterprise customers generate the highest lifetime value and the strongest CLV:CAC ratio,
-- making them the most profitable customer segment. 
-- Starter customers exhibit the lowest lifetime value and weakest CLV:CAC ratio, 
-- suggesting that acquisition costs are barely recovered before these customers churn.

#=========================
# CUSTOMER SEGMENTATION
#=========================

WITH segmented_stats AS(
	SELECT
		plan,
		industry,
		company_size,
		COUNT(customer_id) AS total_customers,
		SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churn_customer,
		ROUND(AVG(feature_usage_pct), 2) AS avg_feature_usage,
		ROUND(AVG(nps_score), 2) AS avg_nps
	FROM subscriptions_cl
	GROUP BY plan, industry, company_size
)
SELECT 
	plan,
	industry,
	company_size,
	total_customers,
	avg_feature_usage,
	avg_nps,
	CONCAT(ROUND(churn_customer * 100 / total_customers, 2), '%') AS churn_rate
FROM segmented_stats
ORDER BY plan, industry, company_size;



#=========================
# FEATURE USAGE ANALYSIS
#=========================

WITH feature_bucket AS (
	SELECT
		plan,
		churned,
		feature_usage_pct,
		CASE	
			WHEN feature_usage_pct < 30 THEN 'Low'
			WHEN feature_usage_pct >=30 AND feature_usage_pct < 70 THEN 'Medium'
			ELSE 'High'
		END AS usage_bucket
	FROM subscriptions_cl
)
SELECT
	plan,
	churned,
	COUNT(*) AS Total_Customes,
    ROUND(AVG(feature_usage_pct), 2) AS Avg_feature_usage,
    COUNT(CASE WHEN usage_bucket = 'Low' THEN 1 END) AS low_usage_count,
    COUNT(CASE WHEN usage_bucket = 'Medium' THEN 1 END) AS medium_usage_count,
	COUNT(CASE WHEN usage_bucket = 'High' THEN 1 END) AS high_usage_count
FROM feature_bucket
GROUP BY churned, plan
ORDER BY churned, plan;



#=========================
# NPS ANALYSIS
#=========================

# 1.NPS Impact on Churn 

 WITH nps_distribution AS(
SELECT
	nps_score,
    churned,
    customer_id,
    CASE 
		WHEN nps_score <=5  THEN 'Detractors'
		WHEN nps_score BETWEEN 7 AND 8 THEN 'Passives'
        ELSE 'Promoters'
	END AS NPS_Bucket
FROM subscriptions_cl
)
SELECT
	NPS_Bucket,
	COUNT(customer_id) AS Total_Customers,
    SUM(CASE WHEN churned = 'Yes'THEN 1 ELSE 0 END) AS churned_customer,
    ROUND(
		SUM(CASE WHEN churned = 'Yes'THEN 1 ELSE 0 END) * 100 /
			COUNT(customer_id), 
		2) AS churn_rate
FROM nps_distribution
GROUP BY NPS_Bucket;


# 2. NPS + Feature Usage Impact on Churn 

 WITH feature_bucket AS(                            # 1ST CTE CAL. FEATURE BUCKET
	SELECT
		customer_id,
		plan,
		CASE 
			WHEN feature_usage_pct < 30 THEN 'Low'
			WHEN feature_usage_pct >=30 AND feature_usage_pct < 70 THEN 'Medium'
			ELSE 'High'
		END AS feat_bucket
	FROM subscriptions_cl
),
nps_bucket AS(                                             # 2ND CTE CAL. NPS BUCKET
	SELECT
		nps_score,
		churned,
		customer_id,
		CASE 
			WHEN nps_score <=5  THEN 'Detractors'
			WHEN nps_score BETWEEN 7 AND 8 THEN 'Passives'
			ELSE 'Promoters'
		END AS nps_bucket
	FROM subscriptions_cl
),
comb_t1 AS (                                  # 3RD CTE JOIN LAST 2 CTE feature_bucket & nps_bucket
	SELECT
		COUNT(f.customer_id) AS Total_Customer,
        f.feat_bucket,
        n.nps_bucket,
        SUM(CASE WHEN churned = 'Yes'THEN 1 ELSE 0 END) AS churned_customer
	FROM feature_bucket f
    JOIN nps_bucket n
		ON f.customer_id = n.customer_id
	GROUP BY f.feat_bucket, n.nps_bucket	
    HAVING SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) > 0
)
SELECT                                                 # FINAL & OUTER QUERY, CONSILDATE THE WHOLE DATA USING JOIN CTE 
    feat_bucket,
    nps_bucket,
    CONCAT(ROUND((churned_customer * 100 / Total_Customer),
		2), '%') AS churn_rate
FROM comb_t1
GROUP BY feat_bucket, nps_bucket
ORDER BY churn_rate DESC;


#=========================
# AT-RISK INDICATOR 
#=========================

 WITH at_risk AS(
	SELECT 
		*,
		CASE WHEN feature_usage_pct < 30 THEN 'High Risk' ELSE 'Normal' END AS feature_risk,
        CASE WHEN nps_score <= 6 THEN 'At Risk' ELSE 'Happy' END AS nps_risk,
        CASE WHEN feature_usage_pct < 30 OR nps_score <= 6 THEN 1 ELSE 0 END  AS risk
	FROM subscriptions_cl
	WHERE churned = 'No'
)
SELECT
	COUNT(*) AS total_active,
    SUM(risk) AS at_risk_customers,
    CONCAT(ROUND(SUM(risk) * 100.0 / COUNT(*), 2), '%') AS risk_percentage
FROM at_risk;

 

#=========================
 #COHORT ANALYSIS
#=========================

SELECT
	signup_date AS Cohort,
    COUNT(customer_id) AS Total_Customer,
	SUM(CASE WHEN churned = 'No' THEN 1 ELSE 0 END) AS Active_Customers,
	SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS Churn_Customers,
    CONCAT(ROUND(
		(SUM(CASE WHEN churned = 'No' THEN 1 ELSE 0 END) /
			COUNT(customer_id) * 100.0), 2), '%') AS Retention
FROM subscriptions_cl
GROUP BY Cohort
ORDER BY Cohort;

#=========================
 #RISK MATRIX
 #=========================

SELECT 	
	CASE 
		WHEN feature_usage_pct < 30 THEN 'Low'
		WHEN feature_usage_pct >=30 AND feature_usage_pct < 70 THEN 'Medium'
		ELSE 'High'
	END AS Feature_Usage_Bucket,
    CASE 
			WHEN nps_score <=5  THEN 'Detractors'
			WHEN nps_score BETWEEN 6 AND 8 THEN 'Passives'
			ELSE 'Promoters'
		END AS nps_bucket,
	COUNT(customer_id) AS Total_Customers,
    CONCAT(ROUND(SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0
		/ COUNT(customer_id), 2), '%')  AS Churn_Rate
FROM subscriptions_cl
GROUP BY Feature_Usage_Bucket, nps_bucket
ORDER BY Churn_Rate DESC;

