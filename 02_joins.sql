-- ============================================
-- 02_JOINS.SQL
-- JOIN Types: INNER, LEFT, RIGHT, CROSS, SELF
-- ============================================

-- ==========================================
-- 1. INNER JOIN: Films with their language
-- ==========================================
-- Concept: INNER JOIN - Only matching rows from both tables
-- Returns: Films only if language exists

SELECT f.film_id, f.title, l.name as language
FROM film f 
INNER JOIN language l ON f.language_id = l.language_id;


-- ==========================================
-- 2. INNER JOIN: Customer rentals with film details
-- ==========================================
-- Concept: Multiple INNER JOINs (3+ tables)
-- Returns: Customer name, rental date, film title

SELECT c.first_name, c.last_name, 
       r.rental_date, f.title
FROM rental r 
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
ORDER BY r.rental_date DESC
LIMIT 10;


-- ==========================================
-- 3. LEFT JOIN: All customers with their rentals (including no rentals)
-- ==========================================
-- Concept: LEFT JOIN - All left table rows + matching right
-- Returns: All customers even if they haven't rented

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) as rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC;


-- ==========================================
-- 4. LEFT JOIN: Find customers who never made a payment
-- ==========================================
-- Concept: LEFT JOIN with NULL check
-- Returns: Customers with no payment records

SELECT c.customer_id, c.first_name, c.last_name
FROM customer c 
LEFT JOIN payment p ON c.customer_id = p.customer_id 
WHERE p.payment_id IS NULL;


-- ==========================================
-- 5. LEFT JOIN: All cities with their address count (including zero)
-- ==========================================
-- Concept: LEFT JOIN with COUNT for null handling
-- Returns: All cities with address count (0 if none)

SELECT ci.city_id, ci.city,
       COUNT(a.address_id) as address_count
FROM city ci
LEFT JOIN address a ON ci.city_id = a.city_id
GROUP BY ci.city_id, ci.city
ORDER BY address_count DESC;


-- ==========================================
-- 6. RIGHT JOIN: All rentals with staff name (including no staff)
-- ==========================================
-- Concept: RIGHT JOIN - All right table rows + matching left
-- Returns: All rentals even if staff not found

SELECT r.rental_id, r.rental_date,
       CONCAT(s.first_name, ' ', s.last_name) as staff_name
FROM staff s 
RIGHT JOIN rental r ON s.staff_id = r.staff_id
LIMIT 20;


-- ==========================================
-- 7. RIGHT JOIN: All stores with their inventory
-- ==========================================
-- Concept: RIGHT JOIN counting
-- Returns: All inventory with store info

SELECT s.store_id, s.address_id,
       COUNT(i.inventory_id) as inventory_count
FROM store s
RIGHT JOIN inventory i ON s.store_id = i.store_id
GROUP BY s.store_id, s.address_id
ORDER BY inventory_count DESC;


-- ==========================================
-- 8. CROSS JOIN: All possible combinations of actors and categories
-- ==========================================
-- Concept: CROSS JOIN - Cartesian product (all combinations)
-- Returns: Every actor paired with every category

SELECT a.actor_id, a.first_name,
       c.category_id, c.name
FROM actor a
CROSS JOIN category c 
LIMIT 100;


-- ==========================================
-- 9. CROSS JOIN: Staff and Store combinations
-- ==========================================
-- Concept: CROSS JOIN for analysis
-- Returns: All staff-store combinations

SELECT s.staff_id, CONCAT(s.first_name, ' ', s.last_name) as staff_name,
       st.store_id
FROM staff s
CROSS JOIN store st 
ORDER BY s.staff_id;


-- ==========================================
-- 10. SELF JOIN: Find actor pairs with same last name
-- ==========================================
-- Concept: SELF JOIN - Join table to itself
-- Returns: Pairs of actors sharing last name

SELECT 
    a1.actor_id as actor1_id,
    a1.first_name as actor1_first_name,
    a1.last_name,
    a2.actor_id as actor2_id,
    a2.first_name as actor2_first_name
FROM actor a1
INNER JOIN actor a2 ON 
    a1.last_name = a2.last_name
    AND a1.actor_id < a2.actor_id
ORDER BY a1.last_name;


-- ==========================================
-- 11. SELF JOIN: Find customers in same city
-- ==========================================
-- Concept: SELF JOIN for relationship discovery
-- Returns: Pairs of customers in same city

SELECT  
    c1.customer_id as customer1_id,
    c1.first_name as customer1_name,
    c2.customer_id as customer2_id,
    c2.first_name as customer2_name,
    a.city_id
FROM customer c1
INNER JOIN address a ON c1.address_id = a.address_id 
INNER JOIN customer c2 ON 
    c2.address_id = a.address_id
    AND c1.customer_id < c2.customer_id
ORDER BY a.city_id
LIMIT 50;


-- ==========================================
-- 12. Multiple JOINs: Customer info with address, city, country
-- ==========================================
-- Concept: 4-table JOIN
-- Returns: Complete customer location details

SELECT c.customer_id, c.first_name, c.last_name,
       a.address, ci.city, co.country
FROM customer c 
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
ORDER BY c.customer_id;


-- ==========================================
-- 13. Complex 5-Table JOIN: Film rental analysis
-- ==========================================
-- Concept: Complex multi-table JOIN
-- Returns: Complete rental transaction details

SELECT f.film_id, f.title, 
       c.first_name, c.last_name,
       r.rental_date, p.amount, p.payment_date
FROM film f 
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN payment p ON r.rental_id = p.rental_id
ORDER BY r.rental_date DESC
LIMIT 20;


-- ==========================================
-- 14. LEFT JOIN with GROUP BY: Stores with customer count
-- ==========================================
-- Concept: LEFT JOIN for complete picture
-- Returns: All stores with customer count (0 if none)

SELECT s.store_id, a.address,
       COUNT(c.customer_id) as customer_count
FROM store s
LEFT JOIN customer c ON s.store_id = c.store_id
INNER JOIN address a ON s.address_id = a.address_id
GROUP BY s.store_id, a.address
ORDER BY customer_count DESC;


-- ==========================================
-- 15. Multiple LEFT JOINs: Films with ratings and rental info
-- ==========================================
-- Concept: Multiple LEFT JOINs
-- Returns: All films with rental counts (0 if never rented)

SELECT f.film_id, f.title, f.rating,
       COUNT(r.rental_id) as rental_count,
       COUNT(DISTINCT c.customer_id) as unique_customers
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN customer c ON r.customer_id = c.customer_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY rental_count DESC
LIMIT 20;


-- ==========================================
-- 16. UNION: Combine cities from address and store tables
-- ==========================================
-- Concept: UNION - Combine results, remove duplicates
-- Returns: Unique cities from both tables

SELECT c.city FROM address a
INNER JOIN city c ON c.city_id = a.city_id
UNION
SELECT c.city FROM store s 
INNER JOIN address a ON a.address_id = s.address_id
INNER JOIN city c ON c.city_id = a.city_id;


-- ==========================================
-- 17. UNION ALL: All cities including duplicates
-- ==========================================
-- Concept: UNION ALL - Include duplicates
-- Returns: All cities from both tables (with duplicates)

SELECT c.city FROM address a
INNER JOIN city c ON c.city_id = a.city_id
UNION ALL
SELECT c.city FROM store s 
INNER JOIN address a ON a.address_id = s.address_id
INNER JOIN city c ON c.city_id = a.city_id;


-- ==========================================
-- 18. Complex analysis: Top customers by city
-- ==========================================
-- Concept: Multiple JOINs with grouping
-- Returns: Top spenders per city

SELECT c.customer_id, c.first_name, c.last_name,
       ci.city, co.country,
       SUM(p.amount) as total_spent,
       COUNT(r.rental_id) as rental_count
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, ci.city, co.country
ORDER BY total_spent DESC
LIMIT 20;


-- ==========================================
-- 19. Actor-Film network: Films with actor counts
-- ==========================================
-- Concept: Multiple JOINs with COUNT(DISTINCT)
-- Returns: Films with their actor counts

SELECT f.film_id, f.title,
       COUNT(DISTINCT fa.actor_id) as actor_count,
       GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) 
                   ORDER BY a.last_name 
                   SEPARATOR ', ') as actors
FROM film f
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id, f.title
ORDER BY actor_count DESC
LIMIT 20;


-- ==========================================
-- 20. Store performance: Sales by store and staff
-- ==========================================
-- Concept: Complex multi-table JOIN with aggregation
-- Returns: Sales metrics per store and staff

SELECT s.store_id, st.staff_id,
       CONCAT(st.first_name, ' ', st.last_name) as staff_name,
       COUNT(DISTINCT r.rental_id) as rentals,
       COUNT(DISTINCT p.payment_id) as payments,
       SUM(p.amount) as total_revenue
FROM store s
LEFT JOIN staff st ON s.store_id = st.store_id
LEFT JOIN customer c ON s.store_id = c.store_id
LEFT JOIN rental r ON c.customer_id = r.customer_id AND r.staff_id = st.staff_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY s.store_id, st.staff_id, st.first_name, st.last_name
ORDER BY total_revenue DESC;

-- End of JOINs
