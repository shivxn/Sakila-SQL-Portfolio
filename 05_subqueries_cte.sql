-- ============================================
-- 05_SUBQUERIES_CTE.SQL
-- Subqueries, CTEs (WITH), Complex Logic
-- ============================================

-- ==========================================
-- 1. Find customers with rentals > 20 using CTE
-- ==========================================
-- Concept: CTE (Common Table Expression) with WHERE
-- Returns: Customers with more than 20 rentals

WITH customer_rental_count AS (
    SELECT r.customer_id,
           COUNT(*) as rental_count  
    FROM rental r  
    GROUP BY r.customer_id
)
SELECT c.customer_id, c.first_name, c.last_name,
       crc.rental_count
FROM customer c 
JOIN customer_rental_count crc ON c.customer_id = crc.customer_id 
WHERE crc.rental_count > 20
ORDER BY rental_count DESC;


-- ==========================================
-- 2. Top spending customer per store with CTE
-- ==========================================
-- Concept: Multiple CTEs in sequence
-- Returns: Highest spending customer per store

WITH customer_spending AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(p.amount) as spending, c.store_id
    FROM customer c 
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.store_id
),
ranked_customers AS (
    SELECT customer_id, first_name, last_name,
           spending, store_id,
           RANK() OVER (PARTITION BY store_id 
                       ORDER BY spending DESC) as rnk
    FROM customer_spending
)
SELECT customer_id, first_name, last_name,
       spending, store_id
FROM ranked_customers
WHERE rnk = 1;


-- ==========================================
-- 3. Find customers > store average rentals with CTE
-- ==========================================
-- Concept: Multiple CTEs with JOIN
-- Returns: Customers above their store average

WITH customer_rental_count AS (
    SELECT c.customer_id, c.store_id,
           COUNT(r.rental_id) as rental_count 
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id 
    GROUP BY c.customer_id, c.store_id 
),
store_average AS (
    SELECT store_id,
           AVG(rental_count) as avg_rental_per_customer
    FROM customer_rental_count 
    GROUP BY store_id 
)
SELECT crc.customer_id, crc.rental_count, crc.store_id, 
       sa.avg_rental_per_customer
FROM customer_rental_count crc 
JOIN store_average sa ON crc.store_id = sa.store_id 
WHERE crc.rental_count > sa.avg_rental_per_customer
ORDER BY crc.store_id, crc.rental_count DESC;


-- ==========================================
-- 4. Find actors in action but not comedy films
-- ==========================================
-- Concept: Set operations (EXCEPT logic using NOT IN)
-- Returns: Actors who acted in action films but not comedy

SELECT DISTINCT a.actor_id, a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id 
JOIN film_category fc ON f.film_id = fc.film_id 
JOIN category c ON fc.category_id = c.category_id 
WHERE c.name = 'Action'
  AND a.actor_id NOT IN (
      SELECT DISTINCT a2.actor_id
      FROM actor a2
      JOIN film_actor fa2 ON a2.actor_id = fa2.actor_id
      JOIN film f2 ON fa2.film_id = f2.film_id 
      JOIN film_category fc2 ON f2.film_id = fc2.film_id 
      JOIN category c2 ON fc2.category_id = c2.category_id 
      WHERE c2.name = 'Comedy'
  );


-- ==========================================
-- 5. Find films never rented using NOT IN
-- ==========================================
-- Concept: Subquery in WHERE clause
-- Returns: Films with zero rentals

SELECT f.film_id, f.title
FROM film f 
WHERE f.film_id NOT IN (
    SELECT DISTINCT i.film_id 
    FROM inventory i
    WHERE i.inventory_id IN (
        SELECT r.inventory_id 
        FROM rental r
    )
);


-- ==========================================
-- 6. Find customers with rentals using EXISTS
-- ==========================================
-- Concept: EXISTS subquery (more efficient than IN)
-- Returns: Customers who rented at least one film

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM rental r
    WHERE c.customer_id = r.customer_id 
);


-- ==========================================
-- 7. Find customers who NEVER made a payment using NOT EXISTS
-- ==========================================
-- Concept: NOT EXISTS (inverse of EXISTS)
-- Returns: Customers with no payment records

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c  
WHERE NOT EXISTS (
    SELECT 1 
    FROM payment p
    WHERE p.customer_id = c.customer_id 
);


-- ==========================================
-- 8. Find customers renting 3+ different categories
-- ==========================================
-- Concept: Subquery in FROM clause (derived table)
-- Returns: Customers with diverse film preferences

SELECT c.customer_id, c.first_name, c.last_name,
       category_count, rental_count
FROM customer c 
WHERE c.customer_id IN (
    SELECT r.customer_id
    FROM rental r 
    JOIN inventory i ON r.inventory_id = i.inventory_id 
    JOIN film f ON i.film_id = f.film_id 
    JOIN film_category fc ON f.film_id = fc.film_id 
    GROUP BY r.customer_id
    HAVING COUNT(DISTINCT fc.category_id) >= 3
)
JOIN (
    SELECT customer_id,
           COUNT(DISTINCT fc.category_id) as category_count,
           COUNT(DISTINCT r.rental_id) as rental_count
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id 
    JOIN film f ON i.film_id = f.film_id 
    JOIN film_category fc ON f.film_id = fc.film_id 
    GROUP BY customer_id
) cat_stats ON c.customer_id = cat_stats.customer_id
ORDER BY category_count DESC;


-- ==========================================
-- 9. Correlated subquery: Film compared to average length
-- ==========================================
-- Concept: Correlated subquery in WHERE
-- Returns: Films longer than average in their category

SELECT f.film_id, f.title, c.name as category, f.length,
       (SELECT AVG(f2.length) 
        FROM film f2 
        JOIN film_category fc2 ON f2.film_id = fc2.film_id
        WHERE fc2.category_id = fc.category_id) as category_avg_length
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE f.length > (
    SELECT AVG(f2.length)
    FROM film f2
    JOIN film_category fc2 ON f2.film_id = fc2.film_id
    WHERE fc2.category_id = fc.category_id
)
ORDER BY c.name, f.length DESC;


-- ==========================================
-- 10. Complex CTE chain: Customer lifecycle analysis
-- ==========================================
-- Concept: Multiple dependent CTEs
-- Returns: Complete customer journey metrics

WITH customer_rentals AS (
    SELECT customer_id,
           COUNT(rental_id) as rental_count,
           MIN(rental_date) as first_rental,
           MAX(rental_date) as last_rental
    FROM rental
    GROUP BY customer_id
),
customer_payments AS (
    SELECT customer_id,
           COUNT(payment_id) as payment_count,
           SUM(amount) as total_spent,
           AVG(amount) as avg_payment
    FROM payment
    GROUP BY customer_id
),
customer_lifecycle AS (
    SELECT cr.customer_id,
           cr.rental_count,
           cp.total_spent,
           DATEDIFF(cr.last_rental, cr.first_rental) as customer_lifetime_days,
           CASE 
               WHEN DATEDIFF(NOW(), cr.last_rental) <= 30 THEN 'Active'
               WHEN DATEDIFF(NOW(), cr.last_rental) <= 90 THEN 'At Risk'
               ELSE 'Churned'
           END as status
    FROM customer_rentals cr
    JOIN customer_payments cp ON cr.customer_id = cp.customer_id
)
SELECT c.customer_id, c.first_name, c.last_name,
       cl.rental_count, cl.total_spent, cl.customer_lifetime_days,
       cl.status
FROM customer c
JOIN customer_lifecycle cl ON c.customer_id = cl.customer_id
ORDER BY cl.total_spent DESC;


-- ==========================================
-- 11. Scalar subquery in SELECT
-- ==========================================
-- Concept: Subquery returning single value per row
-- Returns: Film with its category average comparison

SELECT f.film_id, f.title, f.length,
       (SELECT AVG(length) FROM film) as overall_avg_length,
       f.length - (SELECT AVG(length) FROM film) as diff_from_avg,
       (SELECT COUNT(*) FROM inventory i WHERE i.film_id = f.film_id) as stock_count
FROM film f
LIMIT 20;


-- ==========================================
-- 12. Nested subqueries: Complex business logic
-- ==========================================
-- Concept: Nested subqueries (3+ levels)
-- Returns: Top revenue films considering multiple factors

SELECT f.film_id, f.title, revenue
FROM (
    SELECT f.film_id, f.title,
           SUM(p.amount) as revenue,
           ROW_NUMBER() OVER (ORDER BY SUM(p.amount) DESC) as rnk
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY f.film_id, f.title
    HAVING SUM(p.amount) > (
        SELECT AVG(category_revenue)
        FROM (
            SELECT c.category_id,
                   SUM(p2.amount) as category_revenue
            FROM category c
            JOIN film_category fc ON c.category_id = fc.category_id
            JOIN film f2 ON fc.film_id = f2.film_id
            JOIN inventory i2 ON f2.film_id = i2.film_id
            JOIN rental r2 ON i2.inventory_id = r2.inventory_id
            JOIN payment p2 ON r2.rental_id = p2.rental_id
            GROUP BY c.category_id
        ) category_totals
    )
) top_films
WHERE rnk <= 10
ORDER BY revenue DESC;


-- ==========================================
-- 13. UNION ALL with totals row
-- ==========================================
-- Concept: UNION to add summary row
-- Returns: Category revenue with total row

SELECT c.name as category, 
       SUM(p.amount) as revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name

UNION ALL

SELECT 'TOTAL' as category,
       SUM(p.amount) as revenue
FROM payment p
ORDER BY revenue DESC;


-- ==========================================
-- 14. Find staff with above-average performance
-- ==========================================
-- Concept: Subquery with aggregation comparison
-- Returns: Top-performing staff members

SELECT s.staff_id, s.first_name, s.last_name,
       total_revenue, rental_count, customer_count
FROM staff s
JOIN (
    SELECT s.staff_id,
           COUNT(DISTINCT p.payment_id) as rental_count,
           COUNT(DISTINCT c.customer_id) as customer_count,
           SUM(p.amount) as total_revenue
    FROM staff s
    JOIN rental r ON s.staff_id = r.staff_id
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY s.staff_id
) stats ON s.staff_id = stats.staff_id
WHERE total_revenue > (
    SELECT AVG(staff_revenue)
    FROM (
        SELECT s.staff_id,
               SUM(p.amount) as staff_revenue
        FROM staff s
        JOIN rental r ON s.staff_id = r.staff_id
        JOIN payment p ON r.rental_id = p.rental_id
        GROUP BY s.staff_id
    ) staff_stats
)
ORDER BY total_revenue DESC;


-- ==========================================
-- 15. Dynamic segmentation with CASE and subqueries
-- ==========================================
-- Concept: CASE with subqueries for categorization
-- Returns: Customer segments based on multiple metrics

WITH customer_metrics AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           COUNT(r.rental_id) as rental_count,
           SUM(p.amount) as total_spent,
           COUNT(DISTINCT DATE(r.rental_date)) as rental_days
    FROM customer c
    LEFT JOIN rental r ON c.customer_id = r.customer_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, first_name, last_name,
       rental_count, total_spent, rental_days,
       CASE 
           WHEN total_spent >= (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics)
            THEN 'High Value'
           WHEN total_spent >= (SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics)
            THEN 'Medium Value'
           WHEN total_spent >= (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics)
            THEN 'Low Value'
           ELSE 'Inactive'
       END as customer_segment
FROM customer_metrics
WHERE total_spent IS NOT NULL
ORDER BY total_spent DESC;


-- ==========================================
-- 16. Actor performance with multiple aggregations
-- ==========================================
-- Concept: Complex aggregation with subquery comparison
-- Returns: Actor performance vs. average

SELECT a.actor_id, a.first_name, a.last_name,
       film_count, total_revenue,
       avg_revenue_per_film,
       ROUND(film_count / avg_films_per_actor, 2) as productivity_ratio
FROM (
    SELECT a.actor_id, a.first_name, a.last_name,
           COUNT(DISTINCT f.film_id) as film_count,
           ROUND(SUM(p.amount), 2) as total_revenue,
           ROUND(SUM(p.amount) / COUNT(DISTINCT f.film_id), 2) as avg_revenue_per_film
    FROM actor a
    LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
    LEFT JOIN film f ON fa.film_id = f.film_id
    LEFT JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY a.actor_id, a.first_name, a.last_name
) actor_stats
JOIN (
    SELECT AVG(film_count) as avg_films_per_actor
    FROM (
        SELECT COUNT(DISTINCT f.film_id) as film_count
        FROM actor a
        JOIN film_actor fa ON a.actor_id = fa.actor_id
        JOIN film f ON fa.film_id = f.film_id
        GROUP BY a.actor_id
    ) film_counts
) avg_stats
ORDER BY total_revenue DESC
LIMIT 20;


-- ==========================================
-- 17. Find stores managers not in staff table
-- ==========================================
-- Concept: Subquery with NOT IN
-- Returns: Problematic store-manager relationships

SELECT s.store_id, s.manager_staff_id
FROM store s
WHERE s.manager_staff_id NOT IN (
    SELECT st.staff_id 
    FROM staff st 
);


-- ==========================================
-- 18. Category profit margins with CTE
-- ==========================================
-- Concept: CTE with complex calculations
-- Returns: Profit analysis per category

WITH category_costs AS (
    SELECT c.category_id, c.name,
           SUM(f.replacement_cost) as total_replacement_cost,
           COUNT(DISTINCT f.film_id) as film_count
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    GROUP BY c.category_id, c.name
),
category_revenue AS (
    SELECT c.category_id, c.name,
           SUM(p.amount) as total_revenue,
           COUNT(r.rental_id) as rental_count
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.category_id, c.name
)
SELECT cc.name, 
       cr.total_revenue,
       cc.total_replacement_cost,
       ROUND(cr.total_revenue - cc.total_replacement_cost, 2) as net_profit,
       ROUND((cr.total_revenue - cc.total_replacement_cost) / cr.total_revenue * 100, 2) as profit_margin_percent
FROM category_costs cc
JOIN category_revenue cr ON cc.category_id = cr.category_id
ORDER BY net_profit DESC;


-- ==========================================
-- 19. Recursive CTE: Time series data (Example pattern)
-- ==========================================
-- Concept: CTE generating sequences for analysis
-- Returns: Date range for analysis

WITH RECURSIVE date_range AS (
    SELECT '2005-01-01' as analysis_date
    UNION ALL
    SELECT DATE_ADD(analysis_date, INTERVAL 1 MONTH)
    FROM date_range
    WHERE analysis_date < '2005-12-31'
)
SELECT dr.analysis_date,
       COUNT(r.rental_id) as rentals,
       SUM(p.amount) as revenue
FROM date_range dr
LEFT JOIN rental r ON DATE_TRUNC(r.rental_date, MONTH) = DATE_TRUNC(dr.analysis_date, MONTH)
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY dr.analysis_date
ORDER BY dr.analysis_date;


-- ==========================================
-- 20. Comprehensive business intelligence query
-- ==========================================
-- Concept: Multiple CTEs combined with window functions
-- Returns: Executive dashboard metrics

WITH monthly_metrics AS (
    SELECT DATE_TRUNC(r.rental_date, MONTH) as month,
           COUNT(DISTINCT c.customer_id) as active_customers,
           COUNT(r.rental_id) as total_rentals,
           SUM(p.amount) as monthly_revenue
    FROM rental r
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY DATE_TRUNC(r.rental_date, MONTH)
),
growth_metrics AS (
    SELECT month, active_customers, total_rentals, monthly_revenue,
           LAG(monthly_revenue) OVER (ORDER BY month) as prev_month_revenue,
           ROUND((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month)) / 
                  LAG(monthly_revenue) OVER (ORDER BY month) * 100, 2) as revenue_growth_percent
    FROM monthly_metrics
)
SELECT month, active_customers, total_rentals, monthly_revenue,
       prev_month_revenue, revenue_growth_percent,
       SUM(monthly_revenue) OVER (ORDER BY month) as cumulative_revenue
FROM growth_metrics
ORDER BY month;

-- End of Subqueries and CTEs
