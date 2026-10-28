-- LAB | SQL Subqueries
USE sakila;

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT film_id, count(inventory_id) AS film_copies FROM inventory
GROUP BY account_id;

SELECT count(inventory_id) FROM inventory
WHERE film_id IN (
	SELECT film_id 
    FROM film 
    WHERE title = "Hunchback Impossible"
);

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.

SELECT ROUND(avg(length),2) FROM film;

SELECT title, length FROM film
WHERE length > (SELECT ROUND(avg(length),2) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT * FROM actor
	WHERE actor_id IN (
		SELECT actor_id 
		FROM film_actor
		WHERE film_id IN (
			SELECT film_id 
			FROM film 
			WHERE title = 'Alone Trip')
	);
    
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM film
	WHERE film_id IN (
		SELECT film_id FROM film_category
			WHERE category_id IN (
			SELECT category_id FROM category WHERE name = "family"
			)
		);
	
-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT first_name, last_name, email FROM customer AS cust
JOIN address AS ad
ON cust.address_id = ad.address_id
JOIN city
ON ad.city_id = city.city_id
JOIN country
ON city.country_id = country.country_id
WHERE country = 'Canada';

SELECT first_name, last_name, email FROM customer
	WHERE address_id IN (
		SELECT address_id 
		FROM address 
        WHERE city_id IN (
			SELECT city_id 
			FROM city WHERE country_id IN (
				SELECT country_id FROM country WHERE country = 'Canada')
		)
	);

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

SELECT actor_id, count(film_id) AS num_films FROM film_actor
GROUP BY actor_id
ORDER BY num_films DESC;

SELECT title FROM film WHERE film_id IN (
	SELECT film_id FROM film_actor
    WHERE actor_id = 107);
    
-- 7. Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT customer_id, sum(amount) AS total_amount FROM payment
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 1;

SELECT title FROM film 
	WHERE film_id IN (
		SELECT film_id FROM inventory
		WHERE inventory_id IN (
			SELECT inventory_id FROM rental
			WHERE customer_id = (
				SELECT customer_id FROM payment
				GROUP BY customer_id
				ORDER BY sum(amount) DESC
				LIMIT 1)
			)
	);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.
SELECT customer_id, sum(amount) AS total_amount_spent FROM payment
GROUP BY customer_id;

SELECT customer_id, sum(amount) AS total_amount_spent FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
	SELECT avg(total_amount_spent) FROM (
	SELECT customer_id, sum(amount) AS total_amount_spent FROM payment
	GROUP BY customer_id
    ) AS avg_spend
    );