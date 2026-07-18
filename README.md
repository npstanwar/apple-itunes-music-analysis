# Apple iTunes Music Analysis | SQL Business Intelligence Project 

This project analyzes the Apple iTunes relational database using SQL to generate business insights into customer behavior, sales performance, product popularity, artist performance, operational efficiency, and geographic trends. The project demonstrates advanced SQL techniques including joins, Common Table Expressions (CTEs), window functions, aggregate functions, subqueries, and ranking functions to answer real-world business questions and support data-driven decision making. 


## Project Objective

The objective of this project is to analyze the Apple iTunes music store database and provide actionable business insights by exploring customer purchasing behavior, revenue trends, product performance, employee efficiency, and regional sales patterns using SQL.

---

## Dataset Overview

The database consists of 11 relational tables representing different business entities.

- Customers
- Employees
- Invoices
- Invoice Lines
- Tracks
- Albums
- Artists
- Genres
- Playlists
- Playlist Tracks
- Media Types

The relational schema enables multidimensional analysis across sales, customers, products, employees, and geography.
---

## Tools & Technologies

- PostgreSQL
- SQL
- CSV Dataset
- pgAdmin 4
- Git
- GitHub

---

## SQL Concepts Used

- Joins
- Common Table Expressions (CTEs)
- Window Functions
- Aggregate Functions
- Subqueries
- CASE Statements
- Date Functions
- Ranking Functions
- GROUP BY
- HAVING
- Views
- Foreign Keys
- Primary Keys

---

## Business Problems Solved

### Sales & Revenue Analysis

- Monthly revenue trends
- Average invoice value
- Revenue contribution by employees
- Peak sales months and quarters

### Customer Analytics

- Highest spending customers
- Customer lifetime value
- Repeat purchase analysis
- Purchase frequency
- Average time between purchases

### Product & Content Analysis

- Top revenue generating tracks
- Most purchased albums
- Tracks never purchased
- Revenue by genre
- Genre popularity

### Artist Performance

- Highest grossing artists
- Genre performance
- Units sold by genre
- Country-wise genre analysis

### Employee Analysis

- Revenue managed by employees
- Customer allocation
- Employee performance
- Regional contribution

### Geographic Analysis

- Customer distribution by country
- Revenue by country
- High-value markets
- Underserved regions

### Operational Analysis

- Purchase combinations
- Media type usage
- Catalog optimization
- Customer purchase behavior

---

## Key Insights

- Revenue remains relatively stable with moderate monthly fluctuations.
- Average invoice value indicates a micro-transaction purchasing model.
- Revenue contribution is evenly distributed across employees.
- Q1 generates the highest revenue while Q4 records the lowest.
- Rock accounts for more than half of total revenue and dominates sales globally.
- Approximately 1,697 tracks have never been purchased, indicating significant catalog inefficiency.
- Customers frequently purchase multiple tracks from the same album.
- Revenue is primarily volume-driven rather than price-driven.
- The customer base is geographically diverse, with the USA contributing the largest customer base.
- Customer purchase behavior demonstrates strong repeat engagement with opportunities for improving retention.

---

## Business Recommendations

- Promote top-performing Rock artists while diversifying investments across emerging genres.
- Improve visibility for underperforming tracks through bundled promotions.
- Focus marketing campaigns before Q1 to maximize seasonal demand.
- Increase customer engagement to reduce the average purchase interval.
- Expand investment in high-value geographic markets.
- Optimize catalog management by removing or repositioning inactive content.
- Develop personalized recommendations using multi-genre purchasing behavior.
- Continue balanced customer allocation among support representatives for operational stability.


## Installation

Clone the repository

```bash
git clone https://github.com/your-username/Apple-iTunes-Music-Analysis.git
```

Move into the project directory

```bash
cd Apple-iTunes-Music-Analysis
```

Create the database

```sql
CREATE DATABASE itunes_db;
```

Import all CSV files into PostgreSQL.

Run the SQL script

```sql
\i i_tunes_analysis_SQL_V.1.0.sql
```

---

## Sample Analysis

The project includes SQL solutions for:

- Revenue Analysis
- Customer Analytics
- Product Analysis
- Artist Performance
- Employee Performance
- Geographic Analysis
- Customer Retention
- Operational Optimization

---

## Future Improvements

- Interactive Power BI Dashboard
- Tableau Dashboard
- Automated ETL Pipeline
- Recommendation System
- Customer Segmentation
- Predictive Sales Forecasting
- Artist Popularity Prediction
- Cloud Database Deployment

---

## Author

**Nishant Pratap Singh**

LinkedIn: https://www.linkedin.com/in/npstanwar/

GitHub: https://github.com/npstanwar
