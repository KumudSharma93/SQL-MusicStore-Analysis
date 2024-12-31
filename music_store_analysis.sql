/* Q1: Identify the most senior employee by job title.
   This query retrieves the title, last name, and first name of the employee
   with the highest level in the organization. The results are sorted in descending 
   order of job levels, and only the topmost record is retrived. */
SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Determine which countries have issued the highest number of invoices.
   This query counts the total number of invoices for each billing country.
   The results are grouped by billing_country and ordered by the count in descending order
   to show the countries with the most invoices first. */
SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* Q3: Find the top three highest invoice totals.
   This query retrieves the total amount for all invoices, ordered by the total in descending order.
   Using the LIMIT clause, we ensure that only the top three highest totals are returned. */
SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
   Write a query that returns one city that has the highest sum of invoice totals. 
   Return both the city name & sum of all invoice totals
   This query calculates the total revenue generated in each city by summing the `total` column.
   The invoices are grouped by the `billing_city`, and the results are ordered by the total revenue
   in descending order. Using LIMIT 1, the query retrieves the city with the highest total revenue. */
SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Identify the customer who has spent the most money.
   This query joins the `customer` and `invoice` tables to calculate the total spending for each customer.
   The customers are grouped by their unique IDs and names, and the total spending is calculated using SUM.
   The results are ordered by the total spending in descending order, and the LIMIT clause ensures that
   only the highest spender is returned. */
SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY total_spending DESC
LIMIT 1;


/* Q6: Return the email, first name, last name, and genre of all Rock music listeners. Return your list ordered alphabetically by email starting with the letter A.
   This query retrieves distinct customer details (email, first name, last name) who have listened to Rock music.
   The results are ordered alphabetically by email. Two methods are provided to achieve this. */

/* Method 1: Using a subquery to filter track IDs associated with Rock music. */
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id 
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2: Joining all necessary tables to retrieve Rock listeners directly. */
SELECT DISTINCT email AS Email, first_name AS FirstName, last_name AS LastName, genre.name AS Genre
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q7: Identify the artists who have written the most Rock music tracks. Write a query that returns the Artist name and total track count of the top 10 rock bands.
   This query retrieves the names of the top 10 artists who have written the highest number of Rock songs,
   along with their total track count. The results are grouped by artist and ordered in descending order of the track count. */

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q8: Find all tracks longer than the average song length. Return the Name and Milliseconds for each track. 
   Order by the song length with the longest songs listed first.
   This query returns the names and lengths (in milliseconds) of tracks that have a duration longer thanthe average track 
   length in the dataset. The results are ordered by length in descending order to show the longest tracks first. */
    
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;


/* Q9: Find how much each customer has spent on artists.
   This query identifies the total amount spent by each customer on the best-selling artist.
   First, we determine the artist with the highest revenue using a Common Table Expression (CTE). 
   Then, we calculate how much each customer spent on this artist using invoice details. */

/* Step 1: Use a Common Table Expression (CTE) to find the best-selling artist.
   - Calculate the total revenue for each artist by summing the product of `unit_price` and `quantity` from the `invoice_line` table.
   - Use multiple joins to connect `invoice_line` with `track`, `album`, and `artist` tables to group sales by artist.
   - Order the results by total sales in descending order, and limit the output to the top artist. */
WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)
/* Step 2: Calculate the amount spent by each customer on the best-selling artist.
   - Join the `best_selling_artist` CTE with the main query to filter for tracks by the best-selling artist.
   - Use joins to connect the `customer` table with `invoice`, `invoice_line`, and `track` tables.
   - Compute the total amount spent by each customer by summing the product of `unit_price` and `quantity`.
   - Group the results by customer and artist details, and order the output by the total amount spent in descending order. */
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;


/* Q10: Determine the most popular music genre in each country. Determine the most popular genre as the genre with the highest 
   amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number 
   of purchases is shared return all Genres. 
   This query identifies the most purchased music genre for each country. 
   If multiple genres have the same number of purchases, all are returned. */

/* Method 1: Using CTE to calculate popularity and rank genres for each country.
   The ROW_NUMBER() function is used to assign a unique rank (RowNo) to each genre within 
   each country, ordered by the number of purchases in descending order. The query then 
   filters for the top-ranked genres (RowNo = 1). */

/* Step 1: Use a CTE to calculate the number of purchases for each genre in each country.
   - Use joins to connect `invoice_line`, `invoice`, `customer`, `track`, and `genre` tables.
   - Group by `country` and `genre` to calculate the total purchases for each genre in each country.
   - Use ROW_NUMBER() to rank the genres within each country, ordered by purchases in descending order. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
           ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)
/* Step 2: Filter for the top-ranked genres (RowNo = 1) for each country. */
SELECT * 
FROM popular_genre 
WHERE RowNo = 1;


/* Method 2: Using Recursive approach to determine top genres for each country. */
/* Step 1: Calculate the number of purchases for each genre in each country.
   - Use joins to connect `invoice_line`, `invoice`, `customer`, `track`, and `genre` tables.
   - Group by `country` and `genre` to calculate the total purchases for each genre in each country.
   - This forms the base data for comparison. */
WITH RECURSIVE
    sales_per_country AS (
        SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
        FROM invoice_line
        JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
        JOIN customer ON customer.customer_id = invoice.customer_id
        JOIN track ON track.track_id = invoice_line.track_id
        JOIN genre ON genre.genre_id = track.genre_id
        GROUP BY customer.country, genre.name, genre.genre_id
    ),

/* Step 2: Determine the maximum number of purchases for any genre in each country.
   - Group by `country` to calculate the maximum number of purchases (`max_genre_number`) for any genre.
   - This helps identify the most popular genre(s) in each country. */
    max_genre_per_country AS (
        SELECT country, MAX(purchases_per_genre) AS max_genre_number
        FROM sales_per_country
        GROUP BY country
    )
/* Step 3: Retrieve genres that match the maximum purchase count for their country.
   - Join the `sales_per_country` data with the `max_genre_per_country` CTE on the `country` column.
   - Filter rows where the purchase count matches the maximum (`max_genre_number`) for that country.
   - This ensures that all genres tied for the top position are included in the results. */
SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Q11: Find the customer that has spent the most on music in each country. Write a query that returns the country along with the top customer and how much they spent. 
   For countries where the top amount spent is shared, provide all customers who spent this amount.
   This query identifies the top customer based on total spending in each country. 
   If multiple customers share the highest amount, all are returned. */

/* Method 1: Using CTE to rank customers by spending per country.
   The ROW_NUMBER() function is used to assign a unique rank (RowNo) to customers within each country,
   ordered by their total spending in descending order. The query then filters for the top-ranked customers (RowNo = 1). */

/* Step 1: Use a CTE to calculate the total spending for each customer in each country.
   - Join `invoice` with `customer` to group invoices by customer and country.
   - Compute the total spending for each customer using SUM(total).
   - Use ROW_NUMBER() to rank customers within each country by their total spending in descending order. */
WITH Customter_with_country AS (
    SELECT customer.customer_id, first_name, last_name, billing_country, 
           SUM(total) AS total_spending,
           ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
)
/* Step 2: Filter for the top-ranked customer (RowNo = 1) in each country. */
SELECT * 
FROM Customter_with_country 
WHERE RowNo = 1;


/* Method 2: Using Recursive approach to calculate maximum spending per customer per country. */
/* Step 1: Calculate the total spending for each customer in each country.
   - Join the `invoice` table with `customer` to calculate the total spending (`SUM(total)`) for each customer grouped by their `billing_country`.
   - Group by `customer_id`, `first_name`, `last_name`, and `billing_country` to generate a list of all customers along with their total spending per country. */
WITH RECURSIVE 
    customter_with_country AS (
        SELECT customer.customer_id, first_name, last_name, billing_country, 
               SUM(total) AS total_spending
        FROM invoice
        JOIN customer ON customer.customer_id = invoice.customer_id
        GROUP BY customer.customer_id, first_name, last_name, billing_country
    ),
/* Step 2: Determine the maximum spending for any customer in each country.
   - Use the `customter_with_country` CTE to calculate the maximum spending (`max_spending`) for each country.
   - Group by `billing_country` to ensure the maximum spending is calculated for each country separately. */
    country_max_spending AS (
        SELECT billing_country, MAX(total_spending) AS max_spending
        FROM customter_with_country
        GROUP BY billing_country
    )
/* Step 3: Retrieve customers whose total spending matches the maximum spending for their country.
   - Join `customter_with_country` with `country_max_spending` on `billing_country` to align customers with their country's maximum spending threshold.
   - Filter rows where the customer’s `total_spending` matches the `max_spending` for their country.
   - Order the results by `billing_country` for readability. */
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY cc.billing_country;