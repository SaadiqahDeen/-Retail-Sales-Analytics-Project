# -Retail-Sales-Analytics-Project
SQL‑driven retail analytics project analyzing sales trends, product performance, and customer behavior. Includes time‑series EDA, segmentation models, cumulative metrics, and full product/customer reports with KPIs like AOV, ASP, recency, and revenue performance


#  Retail Sales Analytics (SQL Project)

A complete SQL‑based analytics project exploring retail sales performance, customer behavior, and product insights. This project demonstrates end‑to‑end data analysis using SQL Server, including EDA, segmentation, time‑series analysis, and the creation of two structured analytical reports.

---

##  Project Overview  
This project analyzes transactional retail data to uncover trends, performance drivers, and actionable insights. It includes:

- **Exploratory Data Analysis (EDA)**  
- **Product Performance Report**  
- **Customer Behavior Report**  
- **Segmentation Models**  
- **Time‑Series & Cumulative Metrics**  
- **Window Function–Driven Insights**

The goal is to transform raw sales data into meaningful business intelligence for decision‑making.

---

##  1. Exploratory Data Analysis (EDA)

### **Sales Trends**
- Daily, monthly, and yearly revenue patterns  
- Customer count and quantity sold per period  
- Identification of peak and low‑performing months  
- Multiple date‑handling methods: `GROUP BY`, `DATETRUNC`, `FORMAT`

### **Cumulative & Moving Metrics**
- Running (cumulative) sales by month and year  
- Moving average of price  
- Year‑over‑year comparisons using `LAG()`

### **Performance Analysis**
- Product‑level yearly sales  
- Comparison to historical averages  
- Previous‑year vs current‑year performance  
- Classification: *Improved*, *Declined*, *No Change*

### **Part‑to‑Whole Analysis**
- Category contribution to total revenue  
- Percentage share using window functions

### **Segmentation**
- Product cost segmentation  
- Customer segmentation (VIP, Regular, New)

---

##  2. Product Performance Report

A structured SQL report summarizing product‑level performance.

### **Metrics**
- Total orders  
- Total sales  
- Total quantity sold  
- Unique customers  
- Product lifespan (months)

### **KPIs**
- Recency (months since last order)  
- Average Order Revenue  
- Average Monthly Revenue  
- **Average Selling Price (ASP)** — rounded to one decimal

### **Segmentation**
- High Performer  
- Mid Performer  
- Low Performer  

This report highlights top‑performing products and pricing behavior.

---

## 3. Customer Behavior Report

A customer‑level analytics model profiling purchasing patterns.

### **Metrics**
- Total orders  
- Total sales  
- Total quantity  
- Unique products purchased  
- Customer lifespan  
- Recency

### **KPIs**
- Average Order Value (AOV)  
- Age‑based segmentation  
- VIP / Regular / New classification  

This report supports customer retention and targeted marketing strategies.

---

##  Skills Demonstrated
- Advanced SQL (CTEs, window functions, segmentation logic)  
- Time‑series and cumulative analysis  
- Customer & product analytics  
- Business‑oriented KPI design  
- Clean, reproducible SQL workflows  
- Data storytelling through structured reporting  

##  Outcome
This project delivers a comprehensive analytical view of retail performance, transforming raw transactional data into clear insights that support pricing strategy, product optimization, customer segmentation, and revenue growth.

