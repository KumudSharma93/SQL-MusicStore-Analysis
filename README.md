# SQL Project: Music Store Data Analysis  

## Introduction  

This project analyzes data from an online music store to answer key business questions using SQL. The dataset includes various tables representing customer demographics, invoice details, track information, and artist data. Using PostgreSQL as the database management system and pgAdmin as the query interface, the analysis focused on uncovering trends, customer behaviors, and insights to guide business decisions.  

The dataset supports comprehensive investigations into aspects like customer spending, genre preferences, and artist contributions. Queries are structured to address 11 specific questions, ensuring a thorough exploration of the data.  

---

## Project Objectives  

The key objectives of this study include:  

1. **SQL Querying and Analysis**: Leveraging SQL to extract actionable insights from relational datasets.  
2. **Customer Insights**: Understanding customer behaviors, including spending patterns and genre preferences.  
3. **Artist and Genre Analysis**: Identifying top-performing artists and genres across various regions.  
4. **Geographic Trends**: Analyzing invoices and customer preferences across countries and cities.  
5. **Business Recommendations**: Using query results to inform strategic decisions such as promotions and marketing campaigns.  

---

## Tools and Technologies  

- **Database**: PostgreSQL  
- **Interface**: pgAdmin  
- **Techniques**: Data Querying, Aggregations, Ranking, Filtering, Recursive CTEs   

### SQL Concepts and Techniques Used  

- **Aggregations**: SUM, COUNT, AVG  
- **Joins**: INNER JOIN, LEFT JOIN  
- **Filtering**: WHERE, HAVING  
- **Sorting**: ORDER BY  
- **Grouping**: GROUP BY  
- **Common Table Expressions (CTEs)**: Recursive and non-recursive  
- **Subqueries**: Correlated and non-correlated  

---

## Files and Structure  

- **SQL Scripts**:  
  - `music_store_analysis.sql`: Contains all queries for 11 questions addressing business analysis.  

- **Database Schema**:  
  - The project uses the following database schema:  

    ![Database Schema](images/database-schema.png)

---

## Insights  

The project answered the following 11 key business questions:  

1. **Senior Most Employee**: Identified the senior-most employee based on job title.  
2. **Countries with Most Invoices**: Ranked countries by the number of invoices generated.  
3. **Top Invoice Values**: Extracted the top three invoice totals.  
4. **Best Customers by City**: Found the city with the highest revenue, ideal for a promotional music festival.  
5. **Best Customer Overall**: Identified the customer who spent the most money.  
6. **Rock Music Listeners**: Returned customer details (email, first name, last name) who listened to Rock music, ordered alphabetically by email.  
7. **Top Rock Bands**: Ranked artists by the number of Rock tracks, listing the top 10 performers.  
8. **Longest Tracks**: Retrieved track names with lengths longer than the average, sorted by duration.  
9. **Customer Spending by Artist**: Calculated how much each customer spent on artists.  
10. **Popular Genre by Country**: Identified the most purchased music genre for each country, including ties.  
11. **Top Spenders by Country**: Found the top customer(s) by spending for each country, considering ties.  

---

## Conclusion  

This SQL project demonstrated the power of MySQL as a querying tool to derive actionable insights from relational datasets. The analysis highlighted key trends, including:  

- **Customer Behavior**: Insights into spending patterns and genre preferences.  
- **Artist and Genre Performance**: Identification of top artists and genres.  
- **Regional Trends**: Revenue patterns across cities and countries.  

These findings can support targeted marketing campaigns, improved customer engagement, and better resource allocation. 
