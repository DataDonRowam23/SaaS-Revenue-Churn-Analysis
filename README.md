
## 📌 Business Problem

For SaaS companies, sustainable growth depends on acquiring customers, increasing recurring revenue and minimizing customer churn. 

High churn rates can significantly impact profitability and long-term business performance.

This project analyzes customer subscription and revenue data to identify key drivers of churn, evaluate customer retention, measure revenue growth, and uncover opportunities to improve customer lifetime value and overall business performance.

---

## 📂 Dataset Overview

This project uses two datasets:

### Subscription Dataset

Customer-level subscription information including:

- Customer ID
- Subscription Plan
- Billing Cycle
- Industry
- Company Size
- Number of Seats
- Monthly Revenue
- Acquisition Channel
- Region
- Churn Status
- Churn Reason
- Support Tickets
- NPS Score
- Feature Usage Percentage
- Upgrade Status

### Monthly Revenue Dataset

Monthly SaaS performance metrics including:

- Active Customers
- New Customers
- Churned Customers
- Monthly Churn Rate
- Total MRR
- Average Revenue Per Customer (ARPU)
- Customer Acquisition Cost (CAC)

---

## 🧹 Data Cleaning & Preparation

Data cleaning and preprocessing were performed using Python (Pandas).

### Key Steps

- Imported and validated both datasets
- Checked for missing values and data inconsistencies
- Converted date columns into proper datetime format
- Verified revenue and customer metrics
- Handled null values in churn-related fields
- Performed exploratory data analysis (EDA)
- Created derived metrics for churn and revenue analysis

### Tools Used

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn

---

## 🗄️ SQL Analysis

-- Data Cleaning in SQL

##Key Steps Used

-- Fixed company size and region in subscriptons dataset
-- There were no duplicates in both subscriptions and monthly revenue dataset


Business questions answered using the SQL:

### Customer & Churn Analysis

- What is the overall customer churn rate?
- How has churn trended over time?
- Which subscription plans have the highest churn?
- Does billing cycle impact retention?
- What are the top churn reasons?
- How does churn vary by company size and industry?

### Revenue Analysis

- Which plans generate the most revenue?
- Which industries contribute the highest revenue?
- Which regions generate the most revenue?
- Which acquisition channels bring the highest-value customers?

### SaaS Metrics

- Average Revenue Per User (ARPU)
- Customer Acquisition Cost (CAC)
- Customer Lifetime Value (CLV)
- CLV:CAC Ratio by Plan

---

## 📈 Key Insights

### Customer Retention

- Overall churn rate was **52.17%**.
- The **Starter Plan** experienced the highest churn rate (**70.51%**).
- Enterprise customers demonstrated the strongest retention.
- Monthly subscribers churned significantly more than annual subscribers.

### Revenue Performance

- Business and Enterprise plans generated the majority of total revenue.
- North America contributed the highest share of revenue.
- Organic Search was the most effective acquisition channel.

### Customer Behavior

- Budget cuts and pricing concerns were the leading reasons for customer churn.
- Customers with lower product engagement were more likely to churn.
- Higher NPS scores were associated with stronger customer retention.

### Profitability

- Enterprise customers generated the highest estimated Customer Lifetime Value (CLV).
- Starter customers produced the lowest CLV:CAC ratio.
- Enterprise and Business plans were the most profitable customer segments.

---

## 📊 Power BI Dashboard

The dashboard was designed to provide an executive-level overview of SaaS performance through three interactive pages.

### Executive Overview

- Total Customers
- Total MRR
- Churn Rate
- ARPU
- CAC
- Active Customer Trend
- MRR Trend
- New vs Churned Customers

### Revenue Analysis

- Revenue by Plan
- Revenue by Industry
- Revenue by Region
- Revenue by Acquisition Channel

### Churn Analysis

- Churn Rate by Plan
- Churn Rate by Billing Cycle
- Churn Rate by Company Size
- Top Churn Reasons

---

## 📸 Dashboard Screenshots

### Executive Overview

<img width="1057" height="592" alt="1 ov" src="" />


### Revenue Analysis

<img width="1062" height="592" alt="RA" src="" />


### Churn Analysis

<img width="1062" height="592" alt="CA" src="" />


---

## 💡 Recommendations

### Improve Customer Retention

- Encourage customers to switch to annual subscriptions.
- Improve onboarding and engagement for Starter Plan customers.
- Increase feature adoption through targeted customer success initiatives.

### Reduce Churn

- Address pricing concerns through flexible pricing options.
- Improve customer support experience.
- Prioritize development of frequently requested features.

### Increase Revenue

- Focus marketing efforts on high-performing acquisition channels.
- Promote plan upgrades among existing customers.
- Prioritize acquisition of Enterprise and Business customers due to their higher lifetime value.

---

## 🛠️ Tech Stack

- Python
- Pandas
- NumPy
- PostgreSQL
- MySQL
- Power BI
- DAX
- GitHub

---

## 👨‍💻 Author

**Don Rowam**

 Data Analyst transforming data into actionable business insights using SQL,Excel, Tableau, Power BI & Python.

🔗 LinkedIn: (https://www.linkedin.com/in/roniance-wanyonyi-61741336a/?lipi=urn%3Ali%3Apage%3Ad_flagship3_feed%3BIc%2BVDxykQTacIYF9gjwTsA%3D%3D)

---

⭐ If you found this project interesting, feel free to explore the repository and connect with me on LinkedIn.
