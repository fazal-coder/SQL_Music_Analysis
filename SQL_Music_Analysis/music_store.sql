--Q1: Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

--Q2: Which countries have the most Invoices?

SELECT COUNT(*) AS count_no,billing_country FROM invoice
GROUP BY billing_country
ORDER BY count_no DESC

-- Q3: what are top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

-- Q4: Which city has the best customers? We would like to throw a promotional 
-- 	music Festival in the city we made the most money. Write a query that returns 
-- 	one city that has the hightest sum of invoice totals. Return both the city 
-- 	name & sum of all invoice totals

SELECT billing_city,SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC

-- Q5: Who is the best Customer? The customer who has spent the most money will be declared 
-- 	the best customer. Write a query that returns the person who has spent the most money.

SELECT c.customer_id,c.first_name,c.last_name,SUM(i.total) AS total FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1


-- Q6: Write query to return the email, first name, last name , & Genre of all Rock Music listeners. 
-- 	Return you list ordered alphabetically by email starting with A.


SELECT DISTINCT email,first_name,last_name 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock')
ORDER BY email;


-- Q7: Let's invite the artists who have written the most rock music in our dataset. Write a query
-- that returns the Artist name and total track count of the top 10 rock bands?


SELECT ar.artist_id, ar.name, COUNT(ar.artist_id) AS no_of_Songs 
FROM track AS t
JOIN album AS a ON a.album_id = t.album_id
JOIN artist AS ar ON ar.artist_id = a.artist_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY no_of_Songs DESC
LIMIT 10;


--Q8:Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the longest
-- songs listed first.

SELECT name, t.milliseconds FROM track t
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_length 
	FROM track a)
ORDER BY milliseconds DESC;

-- Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, 
-- 	artist name and total spent


WITH best_selling_artist AS (
	SELECT ar.artist_id AS artist_id, ar.name AS artist_name,
	SUM(line.unit_price*line.quantity) AS total_sales
	FROM invoice_line line
	JOIN track t ON t.track_id = line.track_id
	JOIN album a ON a.album_id = t.album_id
	JOIN artist AS ar ON ar.artist_id = a.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album a ON a.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Q10: We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query that
-- returns each country along with the top genre. For countries where the maximum number of
-- purchases is shared return all Genres.


WITH popular_genre AS 
(
    SELECT COUNT(line.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(line.quantity) DESC) AS No_of_row 
    FROM invoice_line line
	JOIN invoice AS i ON i.invoice_id = line.invoice_id
	JOIN customer AS c ON c.customer_id = i.customer_id
	JOIN track AS t ON t.track_id = line.track_id
	JOIN genre AS g ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)

SELECT * FROM popular_genre WHERE No_of_row  <= 1

--Q11: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1









