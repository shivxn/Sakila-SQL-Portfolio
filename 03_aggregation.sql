-- ============================================
-- 03_AGGREGATION.SQL
-- GROUP BY, HAVING, SUM, COUNT, AVG, MAX, MIN
-- ============================================

-- ==========================================
-- 1. Count films per category
-- ==========================================
-- Concept: GROUP BY with COUNT
-- Returns: Film count per category

SELECT c.category_id, c.name as category_name,
       COUNT(f.film_id) as film_count
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id 
JOIN category c ON fc.category_id = c.category_id 
GROUP BY c.category_id, c.name
ORDER BY film_count DESC;


-- ==========================================
-- 2. Total revenue per staff member
-- ==========================================
-- Concept: JOIN with SUM aggregation
-- Returns: Total payment amount per staff

SELECT s.staff_id, s.first_name, s.last_name,
       COUNT(p.payment_id) as payment_count,
       SUM(p.amount) as total_revenue,
       AVG(p.amount) as avg_payment
FROM staff s 
JOIN payment p ON s.staff_id = p.staff_id 
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_revenue DESC;


-- ==========================================
-- 3. Revenue per month
-- ==========================================
-- Concept: GROUP BY with date formatting
-- Returns: Monthly revenue totals

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') as month,
    COUNT(payment_id) as payment_count,
    SUM(amount) as monthly_revenue,
    AVG(amount) as avg_payment,
    MIN(amount) as min_payment,
    MAX(amount) as max_payment
FROM payment 
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month DESC;


-- ==========================================
-- 4. Most popular rental day of the week
-- ==========================================
-- Concept: GROUP BY with DAYNAME function
-- Returns: Rental count per day of week

SELECT 
    DAYNAME(rental_date) as day_of_week,
    COUNT(rental_id) as rental_count
FROM rental 
GROUP BY DAYNAME(rental_date)
ORDER BY rental_count DESC;


-- ==========================================
-- 5. Films with ratings distribution
-- ==========================================
-- Concept: GROUP BY with multiple aggregations
-- Returns: Rating statistics per film rating

SELECT 
    rating,
    COUNT(film_id) as film_count,
    AVG(length) as avg_length,
    AVG(rental_rate) as avg_rental_rate,
    AVG(replacement_cost) as avg_replacement_cost
FROM film
GROUP BY rating
ORDER BY film_count DESC;


-- ==========================================
-- 6. Category revenue ranking
-- ==========================================
-- Concept: Multiple table JOIN with GROUP BY
-- Returns: Revenue per category ranked

SELECT c.name as category,
       COUNT(DISTINCT f.film_id) as film_count,
       COUNT(r.rental_id) as rental_count,
       SUM(p.amount) as total_revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id 
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
GROUP BY c.name
ORDER BY total_revenue DESC;


-- ==========================================
-- 7. Customer spending levels
-- ==========================================
-- Concept: GROUP BY with HAVING (filter groups)
-- Returns: Customers grouped by spending level

SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(r.rental_id) as rental_count,
    SUM(p.amount) as total_spent,
    AVG(p.amount) as avg_payment
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spent > 100
ORDER BY total_spent DESC;


-- ==========================================
-- 8. Identify films never rented
-- ==========================================
-- Concept: LEFT JOIN with NULL check
-- Returns: Films with zero rentals

SELECT f.film_id, f.title,
       COUNT(r.rental_id) as rental_count
FROM film f 
LEFT JOIN inventory i ON f.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) = 0
ORDER BY f.film_id;


-- ==========================================
-- 9. Actors with film count above average
-- ==========================================
-- Concept: GROUP BY with HAVING and subquery
-- Returns: Actors in more films than average

SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(f.film_id) as film_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id 
JOIN film f ON fa.film_id = f.film_id 
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(f.film_id) > (
    SELECT AVG(film_count)
    FROM (
        SELECT fa.actor_id,
               COUNT(f.film_id) as film_count
        FROM film f
        JOIN film_actor fa ON f.film_id = fa.film_id
        GROUP BY fa.actor_id
    ) as sub
)
ORDER BY film_count DESC;


-- ==========================================
-- 10. Categories with above-average film length
-- ==========================================
-- Concept: HAVING with subquery
-- Returns: Categories where avg length > overall avg

SELECT c.category_id, c.name as category,
       AVG(f.length) as avg_length,
       COUNT(f.film_id) as film_count,
       MIN(f.length) as min_length,
       MAX(f.length) as max_length
FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.category_id, c.name
HAVING AVG(f.length) > (
    SELECT AVG(length) FROM film
)
ORDER BY avg_length DESC;


-- ==========================================
-- 11. Films with at least 3 actors and 5+ rentals
-- ==========================================
-- Concept: GROUP BY with multiple HAVING conditions
-- Returns: Popular films with large casts

SELECT f.film_id, f.title,
       COUNT(DISTINCT fa.actor_id) as actor_count,
       COUNT(DISTINCT r.rental_id) as rental_count,
       SUM(p.amount) as total_revenue
FROM film f 
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title
HAVING COUNT(DISTINCT fa.actor_id) >= 3 
   AND COUNT(DISTINCT r.rental_id) > 5
ORDER BY total_revenue DESC;


-- ==========================================
-- 12. Distinct cities per country
-- ==========================================
-- Concept: COUNT(DISTINCT column)
-- Returns: Number of unique cities per country

SELECT c.country_id, c.country,
       COUNT(DISTINCT ci.city_id) as city_count,
       COUNT(DISTINCT a.address_id) as address_count
FROM country c 
JOIN city ci ON c.country_id = ci.country_id
LEFT JOIN address a ON ci.city_id = a.city_id
GROUP BY c.country_id, c.country
ORDER BY city_count DESC
LIMIT 20;


-- ==========================================
-- 13. Rental statistics per customer
-- ==========================================
-- Concept: Multiple aggregations per group
-- Returns: Detailed rental stats per customer

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) as total_rentals,
       COUNT(DISTINCT DATE(r.rental_date)) as rental_days,
       MIN(r.rental_date) as first_rental_date,
       MAX(r.rental_date) as latest_rental_date
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_rentals DESC
LIMIT 20;


-- ==========================================
-- 14. Inventory distribution by store
-- ==========================================
-- Concept: GROUP BY with COUNT and multiple aggregates
-- Returns: Inventory stats per store per category

SELECT s.store_id, c.name as category,
       COUNT(i.inventory_id) as stock_count,
       COUNT(DISTINCT f.film_id) as unique_films
FROM store s
JOIN inventory i ON s.store_id = i.store_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY s.store_id, c.name
ORDER BY s.store_id, stock_count DESC;


-- ==========================================
-- 15. Top 5 most profitable categories
-- ==========================================
-- Concept: GROUP BY ordered aggregation with LIMIT
-- Returns: Top 5 revenue-generating categories

SELECT c.name as category,
       COUNT(DISTINCT f.film_id) as film_count,
       COUNT(DISTINCT r.rental_id) as rental_count,
       SUM(p.amount) as total_revenue,
       AVG(p.amount) as avg_rental_revenue,
       ROUND(SUM(p.amount) / COUNT(DISTINCT f.film_id), 2) as revenue_per_film
FROM category c 
JOIN film_category fc ON c.category_id = fc.category_id 
JOIN film f ON fc.film_id = f.film_id 
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
GROUP BY c.name
ORDER BY total_revenue DESC
LIMIT 5;


-- ==========================================
-- 16. Revenue per actor
-- ==========================================
-- Concept: Complex multi-table GROUP BY
-- Returns: Total revenue contributed by each actor

SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(DISTINCT f.film_id) as film_count,
       COUNT(DISTINCT r.rental_id) as rental_count,
       SUM(p.amount) as contributed_revenue,
       AVG(p.amount) as avg_rental_value
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id 
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id 
JOIN payment p ON r.rental_id = p.rental_id 
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY contributed_revenue DESC
LIMIT 20;


-- ==========================================
-- 17. Store performance comparison
-- ==========================================
-- Concept: Multiple aggregations for comparison
-- Returns: Comparative store metrics

SELECT s.store_id,
       COUNT(DISTINCT c.customer_id) as customer_count,
       COUNT(DISTINCT r.rental_id) as rental_count,
       SUM(p.amount) as total_revenue,
       ROUND(SUM(p.amount) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer,
       ROUND(AVG(p.amount), 2) as avg_payment
FROM store s
LEFT JOIN customer c ON s.store_id = c.store_id
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.store_id
ORDER BY total_revenue DESC;


-- ==========================================
-- 18. Payment distribution analysis
-- ==========================================
-- Concept: GROUP BY with complex aggregations
-- Returns: Payment patterns and statistics

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m-%d') as day,
    COUNT(payment_id) as transaction_count,
    SUM(amount) as daily_revenue,
    AVG(amount) as avg_transaction,
    MIN(amount) as min_transaction,
    MAX(amount) as max_transaction,
    STDDEV(amount) as payment_stddev
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m-%d')
ORDER BY day DESC
LIMIT 30;


-- ==========================================
-- 19. Customer lifecycle metrics
-- ==========================================
-- Concept: Multiple aggregations for analysis
-- Returns: Customer lifecycle stages

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) as total_rentals,
       MIN(r.rental_date) as first_rental,
       MAX(r.rental_date) as last_rental,
       DATEDIFF(MAX(r.rental_date), MIN(r.rental_date)) as days_active,
       SUM(p.amount) as lifetime_value,
       ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) as avg_revenue_per_rental
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_rentals > 10
ORDER BY lifetime_value DESC;


-- ==========================================
-- 20. Film performance matrix
-- ==========================================
-- Concept: Comprehensive film metrics
-- Returns: Complete film performance analysis

SELECT f.film_id, f.title,
       c.name as category,
       COUNT(DISTINCT fa.actor_id) as actor_count,
       COUNT(DISTINCT r.rental_id) as rental_count,
       COUNT(DISTINCT i.inventory_id) as inventory_count,
       SUM(p.amount) as total_revenue,
       ROUND(SUM(p.amount) / COUNT(DISTINCT r.rental_id), 2) as revenue_per_rental,
       f.rental_rate,
       f.replacement_cost
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY f.film_id, f.title, c.name, f.rental_rate, f.replacement_cost
ORDER BY total_revenue DESC
LIMIT 30;

-- End of Aggregation Queries
