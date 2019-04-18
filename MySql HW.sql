-- # Homework Assignment
USE sakila;
SHOW TABLES;
-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name AS "First Name", last_name AS "Last Name" FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor 
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor 
ADD description BLOB
AFTER last_name;

-- SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.
ALTER TABLE actor 
DROP description;
-- Confirming the update: 
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name AS "Last Name", COUNT(*) AS "Number Of Actors" FROM actor
GROUP BY last_name;
-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name AS "Last Name", COUNT(*) AS "Number Of Actors" FROM actor 
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
-- Checking the record: 
SELECT * FROM actor WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
-- query to fix the record
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- Confirming the update: 
SELECT * FROM actor WHERE last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

-- Checking the record: 
SELECT * FROM actor WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- Confirming the update: 
SELECT * FROM actor WHERE last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- confirming the schema
SELECT table_schema AS "Table Schema"
FROM information_schema.tables 
WHERE table_name = 'address';
-- confirming the address table structure
SHOW CREATE TABLE address;
SELECT * FROM address;
DESCRIBE sakila.address;
-- re-create query
CREATE TABLE IF NOT EXISTS address ( 
	address_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
    address varchar(50) NOT NULL,
    address2 varchar(50) DEFAULT NULL,
    district varchar(20) NOT NULL,
    city_id smallint(5) unsigned NOT NULL,
    postal_code varchar(10) DEFAULT NULL,
    phone varchar(20) NOT NULL,
    location geometry NOT NULL,
    last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    KEY idx_fk_city_id (city_id),
    SPATIAL KEY idx_location (location),
    CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE
) 
ENGINE=InnoDB 
AUTO_INCREMENT=606 
DEFAULT CHARSET=utf8;

-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
-- (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
-- Confirming the table values
/*
SELECT first_name, last_name FROM staff;
SELECT * FROM staff;
SELECT address FROM address;
SELECT * FROM address;
*/

SELECT staff.first_name, staff.last_name, address.address FROM address
INNER JOIN staff ON address.address_id = staff.address_id;    

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.
/*
SELECT * FROM staff;
SELECT * FROM payment;
*/

SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS "Total Amount" FROM payment
JOIN staff ON (staff.staff_id = payment.staff_id)
WHERE payment.payment_date LIKE '2005-08%' 
GROUP BY staff.staff_id;  

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
/*
SELECT * from film_actor;
SELECT * from film;
*/

SELECT film.title AS "Film Title", COUNT(film_actor.actor_id) AS "Number Of Actors" FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- sorting based on count
SELECT film.title AS "Film Title", COUNT(film_actor.actor_id) AS "Number Of Actors" FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title
ORDER BY COUNT(film_actor.actor_id) DESC;

-- another way to order - ORDER BY Number_Of_Actors DESC; change the column name


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
/*
SELECT * FROM inventory WHERE film_id = 439; 
SELECT * from film where title = "Hunchback Impossible";
*/

SELECT COUNT(*) FROM inventory
WHERE film_id IN (
    SELECT film_id FROM film
    WHERE title = 'Hunchback Impossible');
    
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:[Total amount paid](Images/total_payment.png)
/* 
SELECT * FROM payment;
SELECT * FROM customer;
*/

SELECT customer.first_name AS "FIRST NAME", customer.last_name AS "LAST NAME", SUM(payment.amount) AS "TOTAL PAID"
FROM payment 
JOIN customer ON (customer.customer_id = payment.customer_id)
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN ( SELECT language_id FROM language
																WHERE name = "English") ;

-- confirming the result
/*
SELECT * FROM film where language_id = 1 AND title LIKE 'K%' OR title LIKE 'Q%'	;
SELECT language_id FROM language where name = "English";
*/

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
/*
SELECT * from actor;
SELECT * from film_actor where film_id = 17; 
SELECT * from film where title = "Alone Trip";
*/

SELECT first_name AS "First Name" , last_name AS "Last Name" FROM actor
WHERE actor_id IN
(
  SELECT actor_id FROM film_actor
  WHERE film_id IN
  (
    SELECT film_id FROM film
    WHERE title = 'ALONE TRIP'
  )
);

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
-- Checking the data
/*
SELECT * FROM country where country = "Canada";
SELECT * FROM customer;
SELECT * FROM address;
*/

-- Query
SELECT country AS "Country", last_name AS "LAST NAME", first_name AS "First Name", email AS "EMAIL ID" FROM country
LEFT JOIN customer
ON country.country_id = customer.customer_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
-- SELECT * FROM film_list;

SELECT title AS "Film Title", category AS "Movie Category" FROM film_list
WHERE category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
/*
SELECT * FROM film;
SELECT * FROM rental;
SELECT * FROM inventory;
*/

SELECT film.title, COUNT(rental.rental_date) AS "Rental_Count" FROM film 
INNER JOIN inventory ON (film.film_id = inventory.film_id)
INNER JOIN rental ON (inventory.inventory_id = rental.inventory_id)
GROUP BY film.title
ORDER BY Rental_Count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
/*
SELECT * FROM store;
SELECT * FROM payment;
SELECT * FROM customer;
SELECT * FROM staff;
*/

SELECT store.store_id AS "Store", SUM(payment.amount) AS "Business, In Dollars" FROM store 
INNER JOIN staff ON store.store_id = staff.store_id
INNER JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id;

/* another try 
SELECT store.store_id, SUM(payment.amount) as "Business, In Dollars" FROM store 
INNER JOIN customer ON store.store_id = customer.store_id
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY store.store_id;

SELECT store.store_id, SUM(payment.amount) AS "Business, In Dollars" FROM store
JOIN payment ON (payment.staff_id = store.manager_staff_id)
GROUP BY store.store_id; */



-- 7g. Write a query to display for each store its store ID, city, and country.
/*
SELECT * FROM store;
Select * FROM address;
SELECT * FROM city;
SELECT * FROM country;
*/

SELECT store.store_id, city.city, country.country FROM store
JOIN address ON (address.address_id=store.address_id)
JOIN city ON (city.city_id=address.city_id)
JOIN country ON (country.country_id=city.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
/*
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;
*/
-- Query
SELECT category.name AS Top_five, SUM(amount) AS Gross_Revenue FROM category 
INNER JOIN film_category ON  category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY top_five 
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
	SELECT category.name AS Top_five, SUM(amount) AS Gross_Revenue FROM category 
	INNER JOIN film_category ON  category.category_id = film_category.category_id
	INNER JOIN inventory ON film_category.film_id = inventory.film_id
	INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
	INNER JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY top_five 
	ORDER BY gross_revenue DESC
	LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
-- running the query
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;