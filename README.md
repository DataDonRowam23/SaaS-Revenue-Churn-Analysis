# SaaS-Revenue-Churn-Analysis
This project aims to analyse customer behaviour, revenue trends and churn drivers for a B2B SaaS company, Cloud Task Pro. The goal is to provide actionable insights to support leadership decisions and improve customer retention.

# 📊SaaS Revenue & Churn Analysis Project

## 🚀 Overview

This project analyzes customer behavior, revenue trends, and churn drivers for a B2B SaaS company (**CloudTask Pro**). The goal is to provide actionable insights to support leadership decisions and improve customer retention.

An interactive Excel dashboard was built using advanced analytics techniques to visualize key business metrics such as churn rate, MRR, customer engagement, and risk segmentation.



## 🎯 Objectives

- Analyze overall and segment-wise churn rates  
- Identify high-risk customer segments  
- Evaluate revenue growth trends over time  
- Compare Customer Lifetime Value (CLV) with Customer Acquisition Cost (CAC)  
- Understand how feature usage and NPS impact churn  


## 🧰 Tech Stack
- **Excel (Advanced)**
  - Power Pivot  
  - DAX Measures  
  - Pivot Tables  
  - Data Validation  
- Data Visualization & Dashboard Design  


## 📂 Dataset

The project uses two datasets:

1. **Subscription Data (600 customers)**
   - Customer ID  
   - Plan Type (Starter, Professional, Business, Enterprise)  
   - Billing Cycle (Monthly / Annual)  
   - Churn Status  
   - Feature Usage %  
   - NPS Score  
   - Industry & Company Size  

2. **Monthly Revenue Data (2022–2025)**
   - Monthly MRR  
   - Average Revenue per Customer  


## 📊 Dashboard Features

- 📌 Customer Engagement Funnel  
- 📊 Active vs Churned Customers by Plan  
- 🎯 Feature Usage Gap (Active vs Churned by Industry)  
- 📈 Revenue Trend (Dynamic by Month Selection)  
- 🌍 Revenue Distribution by Region and Plan  
- 🍩 Acquisition Channel Distribution  
- 📉 Customer Sentiment by Company Size  
- 📊 Dynamic KPI Comparison (Billing, Risk, Usage, Upgrade)  


## 🔑 Key Insights


## 🔴 High Churn Rate
- Overall churn rate is ~52%, indicating significant retention challenges
- Churn remains a critical risk despite growing customer base


## 📉 Churn Concentration
- Churn is highest among:
  -> Lower-tier plans (Starter / Professional)
  -> Smaller company segments
- Suggests weaker product fit or lower engagement in these segments


## 💳 Billing Cycle Impact
- Annual subscriptions demonstrate stronger retention
- Monthly customers show higher churn, indicating short-term commitment risk


## 📊 Usage Drives Retention
- Customers with low feature usage (<30%) are significantly more likely to churn
- High engagement strongly correlates with customer retention


## 😊 Customer Sentiment Matters
- Detractors (low NPS) exhibit the highest churn rates
- Promoters are far more likely to remain active


## 📈 Revenue Growth vs Risk
- MRR shows consistent upward growth
- However, high churn undermines long-term revenue stability and expansion potential



## ⚠️ At-Risk Customer Definition
Customers are classified as At-Risk if:
- Feature usage < 30%
- OR NPS score ≤ 6
Approximately 47.83% of active customers fall into this category, indicating a significant opportunity for proactive retention strategies


## 💡 Business Recommendations

### 🔧 Improve Onboarding & Feature Adoption
- Implement guided onboarding flows  
- Encourage early feature usage (activation events)  
- Track low-usage users and trigger engagement actions  



### 💳 Promote Annual Plans
- Offer incentives for annual subscriptions  
- Reduce churn by improving long-term commitment


### 🎯 Target High-Risk Segments
- Focus on:
  - Low usage customers  
  - Low NPS segments  
- Use proactive retention strategies


### 📊 Segment-Based Strategy
- Customize experience by:
  - Company size  
  - Industry  
  - Plan type
 


## 📸 Dashboard Preview

<img width="1897" height="822" alt="image" src="" />



## 📁 Project Structure

📦 SaaS-Revenue-Churn-Analysis
┣ 📄 README.md
┣ 📂 SQL
┃ ┗ churn_analysis.sql
┣ 📂 Data
┃ ┣ subscription_data.csv
┃ ┗ monthly_revenue.csv
┣ 📸 dashboard.png


## 📌 Conclusion

While the company shows strong revenue growth, high churn remains a major concern. Improving customer onboarding, increasing feature adoption, and targeting high-risk segments can significantly enhance retention and long-term growth.
