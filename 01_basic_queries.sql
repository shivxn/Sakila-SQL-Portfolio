-- ============================================
-- 01_BASIC_QUERIES.SQL
-- Basic SQL: SELECT, WHERE, ORDER BY, LIMIT
-- ============================================

-- ==========================================
-- 1. List the first 10 films from the table
-- ==========================================
-- Concept: SELECT with LIMIT
-- Returns: First 10 film IDs and titles

SELECT film_id, title
FROM film 
LIMIT 10;


-- ==========================================
-- 2. Show all customers from India
-- ==========================================
-- Concept: JOIN multiple tables, WHERE filter
-- Returns: All customers located in India

SELECT c.customer_id, c.first_name, c.last_name, co.country
FROM customer c 
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'India';


-- ==========================================
-- 3. Find all films with rating = 'PG'
-- ==========================================
-- Concept: WHERE clause with text filtering
-- Returns: All PG-rated films

SELECT film_id, title, rating
FROM film
WHERE rating = 'PG';


-- ==========================================
-- 4. Get all actors whose first name is 'Nick'
-- ==========================================
-- Concept: WHERE with LIKE (exact match)
-- Returns: All actors named Nick

SELECT actor_id, first_name, last_name
FROM actor 
WHERE first_name = 'Nick';


-- ==========================================
-- 5. List the first name and last name of all staff
-- ==========================================
-- Concept: Simple SELECT projection
-- Returns: All staff members' names

SELECT first_name, last_name
FROM staff;


-- ==========================================
-- 6. Show all films released in 2006
-- ==========================================
-- Concept: WHERE with numeric comparison
-- Returns: All 2006 films

SELECT film_id, title, release_year
FROM film 
WHERE release_year = 2006;


-- ==========================================
-- 7. List all cities in alphabetical order
-- ==========================================
-- Concept: ORDER BY ASC
-- Returns: All cities sorted alphabetically

SELECT city_id, city
FROM city
ORDER BY city ASC;


-- ==========================================
-- 8. Get the top 5 longest films by length
-- ==========================================
-- Concept: ORDER BY DESC with LIMIT
-- Returns: 5 films with longest duration

SELECT film_id, title, length
FROM film 
ORDER BY length DESC
LIMIT 5;


-- ==========================================
-- 9. Show all payments greater than $5
-- ==========================================
-- Concept: WHERE with numeric comparison (>)
-- Returns: All payments above $5

SELECT payment_id, customer_id, amount
FROM payment 
WHERE amount > 5.00;


-- ==========================================
-- 10. Display customers whose last name starts with 'A'
-- ==========================================
-- Concept: WHERE with LIKE pattern matching
-- Returns: All customers with last name starting with A

SELECT customer_id, first_name, last_name
FROM customer 
WHERE last_name LIKE 'A%';


-- ==========================================
-- 11. List all films with their language name
-- ==========================================
-- Concept: INNER JOIN
-- Returns: Film titles with their language

SELECT f.title, l.name as language_name
FROM film f 
JOIN language l ON f.language_id = l.language_id;


-- ==========================================
-- 12. Count how many films each category has
-- ==========================================
-- Concept: GROUP BY with COUNT aggregation
-- Returns: Film count per category

SELECT c.category_id, c.name as category_name,
       COUNT(f.film_id) as no_of_films
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id 
JOIN category c ON fc.category_id = c.category_id 
GROUP BY c.category_id, c.name
ORDER BY no_of_films DESC;


-- ==========================================
-- 13. Show each customer with their rental count
-- ==========================================
-- Concept: GROUP BY with COUNT
-- Returns: Rental count per customer

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) as rental_count
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC;


-- ==========================================
-- 14. Find which store has the highest number of customers
-- ==========================================
-- Concept: GROUP BY with COUNT and LIMIT
-- Returns: Store with most customers

SELECT s.store_id,
       COUNT(c.customer_id) as no_of_customers
FROM store s 
JOIN customer c ON s.store_id = c.store_id 
GROUP BY s.store_id 
ORDER BY no_of_customers DESC
LIMIT 1;


-- ==========================================
-- 15. Show the most rented film (title + rental count)
-- ==========================================
-- Concept: Multiple JOINs with GROUP BY and ORDER BY
-- Returns: Film with highest rental count

SELECT f.film_id, f.title,
       COUNT(r.rental_id) as rental_count
FROM film f 
JOIN inventory i ON f.film_id = i.film_id 
JOIN rental r ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC
LIMIT 1;


-- ==========================================
-- 16. List the total revenue per staff member
-- ==========================================
-- Concept: JOIN with SUM aggregation
-- Returns: Total payment amount per staff

SELECT s.staff_id, s.first_name, s.last_name,
       SUM(p.amount) as total_revenue
FROM staff s 
JOIN payment p ON s.staff_id = p.staff_id 
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_revenue DESC;


-- ==========================================
-- 17. Show the total number of films per actor
-- ==========================================
-- Concept: Multiple JOINs with COUNT
-- Returns: Film count per actor

SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(f.film_id) as no_of_films
FROM film f 
JOIN film_actor fa ON f.film_id = fa.film_id 
JOIN actor a ON fa.actor_id = a.actor_id 
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY no_of_films DESC;


-- ==========================================
-- 18. List all customers who have rented more than 20 times
-- ==========================================
-- Concept: GROUP BY with HAVING clause
-- Returns: Active customers with 20+ rentals

SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) as rental_count
FROM customer c 
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 20
ORDER BY rental_count DESC;


-- ==========================================
-- 19. Show each day's total rentals
-- ==========================================
-- Concept: GROUP BY with date formatting
-- Returns: Rental count per day

SELECT COUNT(rental_id) as rental_count,
       DATE_FORMAT(rental_date, '%Y-%m-%d') as day
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m-%d')
ORDER BY day DESC;


-- ==========================================
-- 20. Count films with replacement cost > $20
-- ==========================================
-- Concept: WHERE with aggregation
-- Returns: Films with high replacement cost

SELECT COUNT(*) as film_count,
       COUNT(DISTINCT film_id) as unique_films
FROM film 
WHERE replacement_cost > 20;

-- End of Basic Queries
