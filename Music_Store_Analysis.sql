/*Q1:  Who is the senior most employee based on job title?*/

Select * from employee order by levels desc limit 5;

/*Q2: Which countries have the most Invoices?*/

Select Count(*) as country_count, billing_country from invoice group by billing_country order by country_count desc;

/*Q3: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/

Select customer.customer_id, customer.first_name,customer.last_name, Sum(invoice.total) as Total from customer 
join invoice on customer.customer_id = invoice.customer_id group by customer.customer_id order by total desc limit 10;

/*Q4:  Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/

Select distinct customer.email, customer.first_name, customer.last_name from customer 
join invoice on customer.customer_id = invoice.customer_id join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in( select track_id from track join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock') order by email;

/*Q5: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/

Select Name, milliseconds from track 
where milliseconds > (select Avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;

/*Q6: Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */

WITH selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, a.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN selling_artist a ON a.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/*Q7: Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

