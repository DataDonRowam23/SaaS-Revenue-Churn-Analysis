=========================================
 SaaS Revenue & Churn Analysis
=========================================

# Project: CloudTask Pro (B2B SaaS)
  Objective: Analyze churn, revenue trends, and customer behavior to identify retention risks and growth opportunities.

  
# Dataset:
1. subscription → customer-level data (plan, churn, usage, NPS, etc.)
2. monthly_revenue → monthly MRR and customer metrics


# Key Focus Areas:
- Churn Analysis (overall and segment-wise)
- Revenue Trends (MRR growth and changes)
- Unit Economics (CLV vs CAC)
- Customer Segmentation (plan, industry, company size)
- Risk Identification (low usage and low NPS)
 

 =========================
 DATA CLEANING
 =========================
# Remove duplicates

WITH Duplicate_CTE AS(
	SELECT 
		*,
        ROW_NUMBER() OVER(PARTITION BY 
			customer_id, plan, billing_cycle, industry, company_size, seats, monthly_revenue, acquisition_channel, region, signup_date, 
            signup_month, signup_year, churned, churn_date, churn_month, churn_year, churn_reason, support_tickets_12mo, nps_score, feature_usage_pct, upgraded)
            AS rn
	FROM subscription_cl
)
SELECT * 
FROM Duplicate_CTE
WHERE rn > 1; 

# Fix company size & region

UPDATE subscription
SET company_size = '11-50' 
WHERE company_size = 'Nov-50';

UPDATE subscription
SET company_size = '01-10' 
WHERE company_size = '01-Oct';

# Cleaned Region
UPDATE subscription
SET region = 'Asia' 
WHERE region = 'Asia Pacific';

UPDATE subscription
SET region = 'South America' 
WHERE region = 'Latin America'; 


=========================
 CHURN ANALYSIS
=========================

# Overall Churn

SELECT 
    ROUND(
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(customer_id), 
    2) AS overall_churn_rate
FROM subscription;


# Churn by plan & company size
 
WITH churn_customer AS(
	SELECT
		plan,
		company_size,
		COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscription
    GROUP BY plan, company_size
 )
 SELECT
	plan,
    company_size,
	CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM churn_customer
ORDER BY churned_rate DESC;



# Churn by billing cycle
 
SELECT
	billing_cycle,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM(
	SELECT 	
		billing_cycle,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscription
    GROUP BY billing_cycle
)t
ORDER BY churned_rate;


# Churn by acquisition channel
 
SELECT
	acquisition_channel,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM(
	SELECT 	
		acquisition_channel,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscription
    GROUP BY acquisition_channel
)t
ORDER BY churned_rate;



# Churn by region
 
SELECT
	region,
    CONCAT(ROUND(
		(churned_customer * 100.0/ Total_Customer), 2), '%') AS churned_rate
FROM (
	SELECT
		region,
        COUNT(customer_id) AS Total_Customer,
        SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churned_customer
	FROM subscription
    GROUP BY region
)t
ORDER BY churned_rate;


========================
 CHURN REASON
======================== 

 # Top 3 Reason by plan/company_size

 
 SELECT 
    plan,
    churn_reason,
    COUNT(*) AS total_churn
FROM subscription
WHERE churned = 'Yes'
GROUP BY plan, churn_reason
ORDER BY total_churn DESC
LIMIT 3;






=========================
 REVENUE ANALYSIS
=========================

# Monthly MRR trend
 
WITH prev_month_mrr AS(
	SELECT
		month_rev,
        total_mrr,
        COALESCE(
			LAG(total_mrr) OVER(ORDER BY month_rev), total_mrr) AS prev_mrr
	FROM monthly_revenue
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
    



=========================
 UNIT ECONOMICS
=========================

 
# CLV vs CAC

WITH churn_rate AS(
	SELECT
		s.plan,
        ROUND(AVG(s.monthly_revenue), 2) AS avg_rev,
		ROUND(SUM(CASE WHEN s.churned = 'Yes' THEN 1 ELSE 0 END) * 1.0 / 
				COUNT(s.customer_id), 4) AS churn_rate
	FROM subscription s
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


=========================
 CUSTOMER SEGMENTATION
=========================

WITH segmented_stats AS(
	SELECT
		plan,
		industry,
		company_size,
		COUNT(customer_id) AS total_customers,
		SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS churn_customer,
		ROUND(AVG(feature_usage_pct), 2) AS avg_feature_usage,
		ROUND(AVG(nps_score), 2) AS avg_nps
	FROM subscription
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



=========================
 FEATURE USAGE ANALYSIS
=========================

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
	FROM subscription
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



=========================
 NPS ANALYSIS
=========================

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
FROM subscription
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
	FROM subscription
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
	FROM subscription
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


=========================
 AT-RISK INDICATOR 
=========================

 WITH at_risk AS(
	SELECT 
		*,
		CASE WHEN feature_usage_pct < 30 THEN 'High Risk' ELSE 'Normal' END AS feature_risk,
        CASE WHEN nps_score <= 6 THEN 'At Risk' ELSE 'Happy' END AS nps_risk,
        CASE WHEN feature_usage_pct < 30 OR nps_score <= 6 THEN 1 ELSE 0 END  AS risk
	FROM subscription
	WHERE churned = 'No'
)
SELECT
	COUNT(*) AS total_active,
    SUM(risk) AS at_risk_customers,
    CONCAT(ROUND(SUM(risk) * 100.0 / COUNT(*), 2), '%') AS risk_percentage
FROM at_risk;

 

=========================
 COHORT ANALYSIS
=========================

SELECT
	signup_year AS Cohort,
    COUNT(customer_id) AS Total_Customer,
	SUM(CASE WHEN churned = 'No' THEN 1 ELSE 0 END) AS Active_Customers,
	SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END) AS Churn_Customers,
    CONCAT(ROUND(
		(SUM(CASE WHEN churned = 'No' THEN 1 ELSE 0 END) /
			COUNT(customer_id) * 100.0), 2), '%') AS Retention
FROM subscription
GROUP BY Cohort
ORDER BY Cohort;

=========================
 RISK MATRIX
 =========================

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
FROM subscription
GROUP BY Feature_Usage_Bucket, nps_bucket
ORDER BY Churn_Rate DESC;

