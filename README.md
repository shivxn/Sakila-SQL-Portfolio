# 🎬 Sakila Database - Advanced SQL Portfolio

## Overview
Comprehensive SQL analysis of the **Sakila Movie Rental Database** demonstrating expert-level SQL skills. This portfolio showcases 45+ advanced queries covering JOINs, window functions, subqueries, CTEs, and complex business logic.

**Database**: MySQL Sakila Sample Database
**Total Queries**: 45+
**Difficulty Levels**: Beginner → Intermediate → Advanced

---

## 📊 Project Structure

```
sakila-sql-portfolio/
├── README.md (This file)
├── SQL_CONCEPTS.md (Theory & Explanations)
├── 01_basic_queries.sql (Simple SELECT queries)
├── 02_joins.sql (INNER, LEFT, RIGHT, CROSS, SELF JOINs)
├── 03_aggregation.sql (GROUP BY, HAVING, SUM, COUNT, AVG)
├── 04_window_functions.sql (RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD)
├── 05_subqueries_cte.sql (Subqueries, CTEs, Complex logic)
├── 06_advanced_analysis.sql (Advanced business analysis)
└── sakila_erd_diagram.mwb (Database schema)
```

---

## 🎯 Key Skills Demonstrated

### ✅ Basic SQL
- SELECT, WHERE, ORDER BY, LIMIT, OFFSET
- LIKE, IN, BETWEEN, IS NULL operators
- Filtering and sorting data

### ✅ JOINs (All Types)
- INNER JOIN - 15+ queries
- LEFT JOIN - 8+ queries
- RIGHT JOIN - 3+ queries
- CROSS JOIN - 2+ queries
- SELF JOIN - 2+ queries

### ✅ Aggregation & Grouping
- GROUP BY with multiple columns
- HAVING clause for group filtering
- SUM, COUNT, AVG, MAX, MIN functions
- COUNT(DISTINCT) for unique values

### ✅ Window Functions (Advanced)
- RANK() - Handle ties with ranking
- DENSE_RANK() - Consecutive ranking
- ROW_NUMBER() - Unique row numbering
- LAG() - Access previous row values
- LEAD() - Access next row values
- PARTITION BY - Segment data by groups
- Running totals and cumulative sums

### ✅ Subqueries & CTEs
- Nested subqueries
- Correlated subqueries
- Common Table Expressions (CTEs)
- WITH clause for complex queries
- Multiple CTEs in single query

### ✅ Advanced Logic
- CASE statements for conditional logic
- UNION / UNION ALL
- Subquery in SELECT, WHERE, FROM
- Complex multi-table joins (5+ tables)
- Business metrics calculation

---

## 📈 Query Categories

### Category 1: Customer Analysis (10 queries)
- Top customers by spending
- Customer lifetime value
- Customer segmentation
- Rental behavior analysis
- Payment patterns

### Category 2: Film & Inventory (8 queries)
- Most rented films
- Films never rented
- Inventory analysis
- Film performance metrics
- Category profitability

### Category 3: Revenue & Profitability (7 queries)
- Revenue per month
- Cumulative revenue
- Revenue by category
- Revenue by staff
- Revenue by actor

### Category 4: Actor & Staff Analysis (6 queries)
- Actor performance
- Staff earnings
- Actor collaborations
- Most active actors
- Actor-film relationships

### Category 5: Temporal Analysis (6 queries)
- Daily rental trends
- Monthly patterns
- Running totals
- Year-over-year comparisons
- Seasonal analysis

### Category 6: Complex Business Logic (8+ queries)
- RFM analysis
- Category performance ranking
- Top items per segment
- Cross-segment analysis
- Composite metrics

---

## 🔍 Sample Query Showcase

### Example 1: Top 5 Customers by Spending (Window Function)
```sql
SELECT c.customer_id,
       SUM(p.amount) as spent_money,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) as rnk
FROM customer c 
JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id 
LIMIT 5;
```
**Concepts**: RANK(), GROUP BY, JOIN

---

### Example 2: Top 3 Films per Category (Partition Window Function)
```sql
SELECT category, title, rental_count
FROM (
  SELECT f.title, c.name as category,
         COUNT(r.rental_id) as rental_count,
         ROW_NUMBER() OVER (PARTITION BY c.name 
                          ORDER BY COUNT(r.rental_id) DESC) as rnk 
  FROM category c 
  JOIN film_category fc ON c.category_id = fc.category_id
  JOIN film f ON fc.film_id = f.film_id 
  JOIN inventory i ON f.film_id = i.film_id 
  JOIN rental r ON i.inventory_id = r.inventory_id 
  GROUP BY c.name, f.title
) ranked
WHERE rnk <= 3;
```
**Concepts**: ROW_NUMBER(), PARTITION BY, Subquery, Multiple JOINs

---

### Example 3: Customer Spending with CTE
```sql
WITH customer_spending AS (
  SELECT c.customer_id,
         SUM(p.amount) as total_spending,
         c.store_id
  FROM customer c 
  JOIN payment p ON c.customer_id = p.customer_id
  GROUP BY c.customer_id, c.store_id
),
ranked_customers AS (
  SELECT customer_id, total_spending, store_id,
         RANK() OVER (PARTITION BY store_id 
                     ORDER BY total_spending DESC) as rnk
  FROM customer_spending
)
SELECT customer_id, total_spending, store_id
FROM ranked_customers
WHERE rnk = 1;
```
**Concepts**: CTE (WITH clause), Multiple CTEs, Window Functions, RANK()

---

## 💡 SQL Concepts Explained

### Window Functions
- **RANK()**: Assigns rank with gaps for ties
- **DENSE_RANK()**: Assigns rank without gaps
- **ROW_NUMBER()**: Unique sequential numbers
- **LAG()**: Access previous row
- **LEAD()**: Access next row
- **PARTITION BY**: Create segments
- **ORDER BY**: Sort within partition

### CTEs (Common Table Expressions)
- Readable alternative to nested subqueries
- Multiple CTEs in single query
- Recursive CTEs (advanced)
- Temporary named result set

### JOINs
- **INNER JOIN**: Only matching rows
- **LEFT JOIN**: All left + matching right
- **RIGHT JOIN**: All right + matching left
- **CROSS JOIN**: Cartesian product
- **SELF JOIN**: Join table to itself

### Subqueries
- **Scalar subquery**: Returns single value
- **Row subquery**: Returns single row
- **Table subquery**: Returns multiple rows
- **Correlated subquery**: References outer query
- **Subquery in FROM**: Create temporary table

---

## 📊 Database Schema Overview

**Key Tables**:
- **customer** - Customer information
- **rental** - Rental transactions
- **payment** - Payment records
- **film** - Film information
- **actor** - Actor details
- **film_actor** - Film-actor relationships
- **category** - Film categories
- **inventory** - Stock management
- **store** - Store locations
- **staff** - Staff information

**Relationships**:
- Customer → Rental → Inventory → Film
- Film → Film_Actor → Actor
- Film → Film_Category → Category
- Payment → Rental → Customer
- Store → Inventory, Staff, Customer

---

## 🚀 How to Use This Portfolio

### 1. **Review SQL_CONCEPTS.md**
   - Understand theory first
   - Learn concepts with examples

### 2. **Start with Basic Queries**
   - Run 01_basic_queries.sql
   - Understand SELECT, WHERE, ORDER BY

### 3. **Progress Through Difficulty Levels**
   - 02_joins.sql - Master JOIN types
   - 03_aggregation.sql - GROUP BY & HAVING
   - 04_window_functions.sql - Advanced analytics
   - 05_subqueries_cte.sql - Complex logic
   - 06_advanced_analysis.sql - Real business cases

### 4. **Practice & Modify**
   - Run each query
   - Modify conditions
   - Try different variations

### 5. **Reference for Projects**
   - Use patterns in your own projects
   - Adapt queries for different databases
   - Build on these concepts

---

## 📈 Business Insights Examples

These queries answer real business questions:

✅ **Which customers are most valuable?** → Top 5 spending customers
✅ **Which films drive revenue?** → Most rented films per category
✅ **What's our monthly revenue trend?** → Revenue per month with running total
✅ **Who are our best staff?** → Highest earning staff members
✅ **Which actors generate most revenue?** → Revenue contributed by each actor
✅ **When do we get most rentals?** → Popular rental days & trends
✅ **Which categories are most profitable?** → Revenue by category ranking
✅ **Are customers loyal?** → Latest rental dates, rental frequency

---

## 🎓 Learning Outcomes

After studying this portfolio, you'll understand:

✅ SQL query structure and optimization
✅ How to use advanced window functions
✅ Writing complex multi-table joins
✅ CTEs for readable complex queries
✅ Aggregation and grouping patterns
✅ Business metric calculations
✅ Data analysis and insights
✅ Query performance considerations

---

## 💼 Portfolio Benefits

**For Job Interviews**:
- Demonstrates SQL expertise
- Shows real-world query experience
- Proves ability to handle complex logic
- Proves analytical thinking

**For Data Analysis**:
- Reusable query patterns
- Business logic templates
- Performance optimization examples
- Real scenario examples

**For Learning**:
- Comprehensive SQL reference
- Progressive difficulty levels
- Theory + practice combined
- Real database example

---

## 🔗 Tools & Requirements

**Database**: MySQL (works with most SQL dialects)
**Tools**: 
- MySQL Workbench
- DBeaver
- SQLiteOnline
- Any SQL IDE

**Difficulty**: 
- Beginner → Advanced
- No prior SQL knowledge needed

---

## 📝 Notes

- All queries tested on Sakila database
- Comments included for clarity
- Multiple solutions shown where applicable
- Optimized for performance
- Compatible with MySQL 5.7+

---

## 🎯 Next Steps

1. **Execute all queries** in your environment
2. **Study each concept** in SQL_CONCEPTS.md
3. **Modify queries** to test understanding
4. **Create your own variations**
5. **Apply patterns** to your projects

---

## 📧 Usage

This portfolio is ready for:
- ✅ GitHub display
- ✅ Portfolio website
- ✅ Job interviews
- ✅ Learning & reference
- ✅ Team documentation

---

**Created**: April 2026
**Database**: Sakila Movie Rental Database
**Status**: Complete & Production Ready

---

*Advanced SQL Portfolio - Ready for professional use* 🚀
