-- ============================================
-- 04_WINDOW_FUNCTIONS.SQL
-- RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD
-- ============================================

-- ==========================================
-- 1. Top 5 customers by spending with RANK
-- ==========================================
-- Concept: RANK() OVER (ORDER BY) - Handle ties with gaps
-- Returns: Top 5 spenders with ranking (gaps for ties)

SELECT c.customer_id, c.first_name, c.last_name,
       SUM(p.amount) as spent_money,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) as spending_rank
FROM customer c 
JOIN payment p ON c.customer_id = p.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spending_rank
LIMIT 5;


-- ==========================================
-- 2. Top 3 customers per city with DENSE_RANK
-- ==========================================
-- Concept: DENSE_RANK() OVER (PARTITION BY ... ORDER BY)
-- Returns: Top 3 spenders per city (no gaps in ranking)

SELECT city, customer_id, customer_name, total_spent, rank_in_city
FROM (
    SELECT ci.city, c.customer_id, 
           CONCAT(c.first_name, ' ', c.last_name) as customer_name,
           SUM(p.amount) as total_spent,
           DENSE_RANK() OVER (PARTITION BY ci.city 
                             ORDER BY SUM(p.amount) DESC) as rank_in_city
    FROM customer c
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY ci.city, c.customer_id, c.first_name, c.last_name
) ranked
WHERE rank_in_city <= 3
ORDER BY city, rank_in_city;


-- ==========================================
-- 3. Top 3 rented films per category with ROW_NUMBER
-- ==========================================
-- Concept: ROW_NUMBER() OVER (PARTITION BY ... ORDER BY)
-- Returns: Top 3 films per category (unique row numbers)

SELECT category, film_id, title, rental_count
FROM (
    SELECT f.film_id, f.title, c.name as category,
           COUNT(r.rental_id) as rental_count,
           ROW_NUMBER() OVER (PARTITION BY c.name 
                             ORDER BY COUNT(r.rental_id) DESC) as row_num 
    FROM category c 
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id 
    JOIN inventory i ON f.film_id = i.film_id 
    JOIN rental r ON i.inventory_id = r.inventory_id 
    GROUP BY c.name, f.film_id, f.title
) ranked
WHERE row_num <= 3
ORDER BY category, row_num;


-- ==========================================
-- 4. Most recent rental per customer with ROW_NUMBER
-- ==========================================
-- Concept: ROW_NUMBER with DESC ordering for latest
-- Returns: Most recent rental per customer

SELECT customer_id, first_name, last_name, rental_id, rental_date
FROM (
    SELECT c.customer_id, c.first_name, c.last_name,
           r.rental_id, r.rental_date,
           ROW_NUMBER() OVER (PARTITION BY c.customer_id
                             ORDER BY r.rental_date DESC) as row_num
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
) ranked
WHERE row_num = 1
ORDER BY customer_id;


-- ==========================================
-- 5. Second highest earning staff member with RANK
-- ==========================================
-- Concept: RANK with WHERE on rank value
-- Returns: Staff with 2nd highest earnings

SELECT * 
FROM (
    SELECT s.staff_id, s.first_name, s.last_name,
           SUM(p.amount) as earning,
           RANK() OVER (ORDER BY SUM(p.amount) DESC) as rnk
    FROM staff s 
    JOIN payment p ON s.staff_id = p.staff_id
    GROUP BY s.staff_id, s.first_name, s.last_name
) ranked
WHERE rnk = 2;


-- ==========================================
-- 6. Previous payment per customer with LAG
-- ==========================================
-- Concept: LAG() - Access previous row value
-- Returns: Current and previous payment amounts

SELECT customer_id, payment_id, amount,
       LAG(amount) OVER (PARTITION BY customer_id 
                        ORDER BY payment_id) as prev_payment,
       amount - LAG(amount) OVER (PARTITION BY customer_id 
                                 ORDER BY payment_id) as payment_diff
FROM payment
LIMIT 20;


-- ==========================================
-- 7. Days between customer rentals with LAG
-- ==========================================
-- Concept: LAG with DATEDIFF for time calculations
-- Returns: Days between consecutive rentals per customer

SELECT customer_id, rental_id, rental_date,
       LAG(rental_date) OVER (PARTITION BY customer_id 
                             ORDER BY rental_date) as prev_rental_date,
       DATEDIFF(rental_date, 
               LAG(rental_date) OVER (PARTITION BY customer_id 
                                     ORDER BY rental_date)) as days_between_rentals
FROM rental
ORDER BY customer_id, rental_date
LIMIT 50;


-- ==========================================
-- 8. Next payment per customer with LEAD
-- ==========================================
-- Concept: LEAD() - Access next row value
-- Returns: Current and next payment amounts

SELECT customer_id, payment_id, amount,
       LEAD(amount) OVER (PARTITION BY customer_id 
                         ORDER BY payment_id) as next_payment
FROM payment
ORDER BY customer_id, payment_id
LIMIT 20;


-- ==========================================
-- 9. Monthly running total per store with window function
-- ==========================================
-- Concept: SUM() OVER (ORDER BY) for running totals
-- Returns: Monthly rentals and cumulative totals per store

SELECT store_id, month, monthly_rental_count,
       SUM(monthly_rental_count) OVER (PARTITION BY store_id 
                                       ORDER BY month) as monthly_running_total
FROM (
    SELECT s.store_id,
           DATE_FORMAT(r.rental_date, '%Y-%m') as month,
           COUNT(r.rental_id) as monthly_rental_count
    FROM store s 
    JOIN customer c ON s.store_id = c.store_id
    JOIN rental r ON c.customer_id = r.customer_id 
    GROUP BY s.store_id, DATE_FORMAT(r.rental_date, '%Y-%m')
) monthly_data
ORDER BY store_id, month;


-- ==========================================
-- 10. Cumulative daily revenue
-- ==========================================
-- Concept: SUM OVER for running total across all data
-- Returns: Daily revenue and cumulative revenue

SELECT payment_date, daily_revenue,
       SUM(daily_revenue) OVER (ORDER BY payment_date) as running_total_revenue
FROM (
    SELECT DATE(payment_date) as payment_date,
           SUM(amount) as daily_revenue
    FROM payment 
    GROUP BY DATE(payment_date)
) daily_data
ORDER BY payment_date;


-- ==========================================
-- 11. Payment percentage per customer
-- ==========================================
-- Concept: Window function for percentage calculations
-- Returns: Each payment as % of customer's total

SELECT customer_id, payment_id, amount,
       SUM(amount) OVER (PARTITION BY customer_id) as customer_total,
       ROUND((amount / SUM(amount) OVER (PARTITION BY customer_id)) * 100, 2) as payment_percent
FROM payment
ORDER BY customer_id, payment_id
LIMIT 30;


-- ==========================================
-- 12. Rank films by rental count per category
-- ==========================================
-- Concept: Multiple ranking functions compared
-- Returns: Film rankings with different ranking methods

SELECT f.film_id, f.title, c.name as category,
       rental_count,
       ROW_NUMBER() OVER (PARTITION BY c.name 
                        ORDER BY rental_count DESC) as row_num,
       RANK() OVER (PARTITION BY c.name 
                   ORDER BY rental_count DESC) as rank_val,
       DENSE_RANK() OVER (PARTITION BY c.name 
                         ORDER BY rental_count DESC) as dense_rank_val
FROM (
    SELECT f.film_id, f.title, c.name,
           COUNT(r.rental_id) as rental_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    LEFT JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title, c.name
) ranked_films
ORDER BY category, rental_count DESC
LIMIT 30;


-- ==========================================
-- 13. Customer rental frequency trend with LAG
-- ==========================================
-- Concept: LAG for trend analysis
-- Returns: Rental patterns and changes per customer

SELECT customer_id,
       DATE_FORMAT(rental_month, '%Y-%m') as month,
       monthly_rentals,
       LAG(monthly_rentals) OVER (PARTITION BY customer_id 
                                 ORDER BY rental_month) as prev_month_rentals,
       monthly_rentals - LAG(monthly_rentals) OVER (PARTITION BY customer_id 
                                                   ORDER BY rental_month) as rental_change
FROM (
    SELECT customer_id,
           DATE_TRUNC(rental_date, MONTH) as rental_month,
           COUNT(*) as monthly_rentals
    FROM rental
    GROUP BY customer_id, DATE_TRUNC(rental_date, MONTH)
) monthly_data
ORDER BY customer_id, month
LIMIT 50;


-- ==========================================
-- 14. Percentile ranking of customer spending
-- ==========================================
-- Concept: PERCENT_RANK() for percentile analysis
-- Returns: Customer spending percentile ranking

SELECT customer_id, first_name, last_name, total_spent,
       PERCENT_RANK() OVER (ORDER BY total_spent) as spending_percentile,
       NTILE(4) OVER (ORDER BY total_spent) as spending_quartile
FROM (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(p.amount) as total_spent
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) customer_spending
ORDER BY total_spent DESC
LIMIT 20;


-- ==========================================
-- 15. Film rental acceleration with LAG/LEAD
-- ==========================================
-- Concept: Compare previous, current, and next values
-- Returns: Rental acceleration/deceleration patterns

SELECT film_id, month, rentals,
       LAG(rentals) OVER (PARTITION BY film_id ORDER BY month) as prev_month,
       LEAD(rentals) OVER (PARTITION BY film_id ORDER BY month) as next_month,
       rentals - LAG(rentals) OVER (PARTITION BY film_id ORDER BY month) as month_change,
       LEAD(rentals) OVER (PARTITION BY film_id ORDER BY month) - rentals as next_month_change
FROM (
    SELECT f.film_id,
           DATE_FORMAT(r.rental_date, '%Y-%m') as month,
           COUNT(*) as rentals
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, DATE_FORMAT(r.rental_date, '%Y-%m')
) monthly_rentals
ORDER BY film_id, month
LIMIT 50;


-- ==========================================
-- 16. Customer value segmentation with NTILE
-- ==========================================
-- Concept: NTILE for quartile/segment analysis
-- Returns: Customers divided into value segments

SELECT customer_id, first_name, last_name, total_spent,
       CASE 
           WHEN ntile_rank = 4 THEN 'Top 25% (Whales)'
           WHEN ntile_rank = 3 THEN 'Second 25% (Loyal)'
           WHEN ntile_rank = 2 THEN 'Third 25% (Active)'
           ELSE 'Bottom 25% (At Risk)'
       END as customer_segment,
       ntile_rank
FROM (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(p.amount) as total_spent,
           NTILE(4) OVER (ORDER BY SUM(p.amount)) as ntile_rank
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) segmented
ORDER BY total_spent DESC;


-- ==========================================
-- 17. Actor collaboration network with window functions
-- ==========================================
-- Concept: Window functions for partnership analysis
-- Returns: Top collaborating actor pairs

SELECT actor1, actor2, film_count,
       RANK() OVER (PARTITION BY actor1 ORDER BY film_count DESC) as actor1_collaboration_rank
FROM (
    SELECT fa1.actor_id as actor1,
           fa2.actor_id as actor2 ,
           COUNT(*) as film_count 
    FROM film_actor fa1
    JOIN film_actor fa2 ON 
        fa1.film_id = fa2.film_id 
        AND fa1.actor_id < fa2.actor_id
    GROUP BY fa1.actor_id, fa2.actor_id 
) collaborations
ORDER BY actor1, film_count DESC;


-- ==========================================
-- 18. Running average of payments with window
-- ==========================================
-- Concept: AVG() OVER with ORDER BY for running average
-- Returns: Payment amount with 7-day running average

SELECT payment_date, daily_total,
       AVG(daily_total) OVER (
           ORDER BY payment_date 
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) as running_avg_7day
FROM (
    SELECT DATE(payment_date) as payment_date,
           SUM(amount) as daily_total
    FROM payment
    GROUP BY DATE(payment_date)
) daily_payments
ORDER BY payment_date;


-- ==========================================
-- 19. Revenue contribution ranking
-- ==========================================
-- Concept: PERCENT_RANK and CUME_DIST for distribution
-- Returns: How much each entity contributes to total

SELECT category, revenue,
       PERCENT_RANK() OVER (ORDER BY revenue) as percent_rank,
       CUME_DIST() OVER (ORDER BY revenue) as cumulative_dist,
       ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) as percent_of_total
FROM (
    SELECT c.name as category,
           SUM(p.amount) as revenue
    FROM category c 
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id 
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id 
    JOIN payment p ON r.rental_id = p.rental_id 
    GROUP BY c.name
) category_revenue
ORDER BY revenue DESC;


-- ==========================================
-- 20. Comprehensive customer analytics with multiple window functions
-- ==========================================
-- Concept: Multiple window functions in single query
-- Returns: Holistic customer metrics

SELECT c.customer_id, c.first_name, c.last_name,
       total_rentals,
       total_spent,
       RANK() OVER (ORDER BY total_spent DESC) as spending_rank,
       ROW_NUMBER() OVER (ORDER BY total_rentals DESC) as rental_frequency_rank,
       ROUND(total_spent / total_rentals, 2) as avg_per_rental,
       NTILE(4) OVER (ORDER BY total_spent) as value_quartile,
       ROUND(PERCENT_RANK() OVER (ORDER BY total_spent) * 100, 2) as spending_percentile,
       first_rental,
       last_rental,
       DATEDIFF(last_rental, first_rental) as customer_lifetime_days
FROM (
    SELECT c.customer_id, c.first_name, c.last_name,
           COUNT(r.rental_id) as total_rentals,
           SUM(p.amount) as total_spent,
           MIN(r.rental_date) as first_rental,
           MAX(r.rental_date) as last_rental
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) customer_metrics
ORDER BY total_spent DESC
LIMIT 30;

-- End of Window Functions
