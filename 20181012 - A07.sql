-- Assuming you disabled the query limits in settings...

USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UCASE(CONCAT(first_name, " ", last_name)) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name,  last_name FROM actor 
	WHERE (UCASE(first_name) = "JOE") OR (UCASE(first_name) = "JOSEPH");

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor 
	WHERE UCASE(last_name) LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name, actor_id, last_update FROM actor 
	WHERE UCASE(last_name) LIKE "%LI%" ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country 
	WHERE lcase(country) IN ("afghanistan", "bangladesh", "china");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
	ADD COLUMN description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor 
	DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(first_name) FROM actor 
	GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(first_name) FROM actor 
	GROUP BY last_name 
    HAVING (count(first_name) >= 2);

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
	SET first_name = "HARPO" 
    WHERE (ucase(first_name) = "GROUCHO" AND ucase(last_name) = "WILLIAMS");

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
	SET first_name = "GROUCHO" 
    WHERE (ucase(first_name) = "HARPO" AND ucase(last_name) = "WILLIAMS");

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, concat(address, ", ", district) AS "address" 
	FROM staff LEFT JOIN address
    ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT sum(amount) AS "total_ring_up", staff.* 
	FROM staff LEFT JOIN payment
    ON staff.staff_id = payment.staff_id
    GROUP BY staff_id;
    
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, count(actor_id)
	FROM film INNER JOIN film_actor
    ON film.film_id = film_actor.film_id
    GROUP BY film.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film_id, count(inventory_id) AS "number_of_copies" 
	FROM inventory 
    WHERE film_id IN (
		SELECT film_id FROM film
			WHERE lcase(title) LIKE "%hunchback impossible%"
	);
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.customer_id, last_name, first_name, sum(amount) AS "total_payments"
	FROM customer LEFT JOIN payment
    ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id
    ORDER BY last_name, first_name;
    
-- Total amount paid
SELECT customer.customer_id, last_name, first_name, sum(amount) AS "total_payments"
	FROM customer LEFT JOIN payment
    ON customer.customer_id = payment.customer_id
    GROUP BY customer.customer_id
    ORDER BY sum(amount), last_name, first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM film
	WHERE language_id IN (
		SELECT language_id FROM language 
			WHERE lcase(name) = "english"
	) AND (title LIKE "K%" 
		OR title LIKE "Q%"
	);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT last_name, first_name FROM actor
    WHERE actor_id IN (
		SELECT actor_id FROM film_actor
			WHERE film_id IN (
				SELECT  film_id FROM film
					WHERE lcase(title) = "alone trip"
			)
	) ORDER BY last_name, first_name;	
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
	FROM customer LEFT JOIN (
		address LEFT JOIN (
			city LEFT JOIN country
            ON city.country_id = country.country_id
        ) ON address.city_id = city.city_id
	) ON customer.address_id = address.address_id
    WHERE lcase(country) = "canada";
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film
	WHERE film_id IN (
		SELECT film_id FROM film_category
			WHERE category_id IN (
				SELECT category_id FROM category
					WHERE lcase(name) = "family"
			)
    );

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.film_id, title, count(rental_id) AS "rental_count" 
	FROM film RIGHT JOIN (
		inventory RIGHT JOIN rental
        ON inventory.inventory_id = rental.inventory_id
    ) ON film.film_id = inventory.film_id
    GROUP BY film.film_id
    ORDER BY count(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(amount) AS "total_business" 
	FROM store RIGHT JOIN (
		rental RIGHT JOIN payment
        ON rental.rental_id = payment.rental_id
	) ON store.manager_staff_id = rental.staff_id
    GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
	FROM store LEFT JOIN (
		address LEFT JOIN (
			city LEFT JOIN country
            ON city.country_id = country.country_id
        ) ON address.city_id = city.city_id
    ) ON store.address_id = address.address_id;

-- BONUS to mimic view sales_by_store
CREATE VIEW store_totals AS 
	SELECT store.*, sum(amount) AS "total_business" 
	FROM store RIGHT JOIN (
		rental RIGHT JOIN payment
        ON rental.rental_id = payment.rental_id
	) ON store.manager_staff_id = rental.staff_id
    GROUP BY store_id;

SELECT concat(city, ", ", country) AS store, concat(first_name, " ", last_name) AS manager, total_business AS "total_sales"
	FROM store_totals LEFT JOIN (
		staff LEFT JOIN (
			address LEFT JOIN (
				city LEFT JOIN country
				ON city.country_id = country.country_id
			) ON address.city_id = city.city_id
		) ON staff.store_id = address.address_id
    ) ON store_totals.manager_staff_id = staff.staff_id
    WHERE city IS NOT NULL;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, sum(amount) AS "gross_revenue"
	FROM category RIGHT JOIN (
		film_category RIGHT JOIN (
			inventory RIGHT JOIN (
				rental RIGHT JOIN payment
                ON rental.rental_id = payment.rental_id
            ) ON inventory.inventory_id = rental.inventory_id 
        ) ON film_category.film_id = inventory.film_id
    ) ON category.category_id = film_category.category_id
    GROUP BY name
    ORDER BY sum(amount) DESC
    LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_cat AS
	SELECT name, sum(amount) AS "gross_revenue"
		FROM category RIGHT JOIN (
			film_category RIGHT JOIN (
				inventory RIGHT JOIN (
					rental RIGHT JOIN payment
					ON rental.rental_id = payment.rental_id
				) ON inventory.inventory_id = rental.inventory_id 
			) ON film_category.film_id = inventory.film_id
		) ON category.category_id = film_category.category_id
		GROUP BY name
		ORDER BY sum(amount) DESC
		LIMIT 5;
        
-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_cat;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top5_cat;