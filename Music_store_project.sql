--QUESTION SET #1 (EASY QUESTION)

-- Q1: WHO IS THE MOST SENIOR EMPLOYEE BASED ON JOB TITLE ??

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q2: WHICH COUNTRIES HAVE THE MOST INVOICES ??

SELECT COUNT(*) AS C, billing_country 
FROM INVOICE
group by billing_country
order by C desc

--Q3: WHAT ARE TOP THREE(3) VALUES OF INVOICE??

SELECT * FROM INVOICE
ORDER BY total desc
LIMIT 3

-- Q4: WHICH CITY HAS THE BEST CUSTOMERS? WE WOULD LIKE TO THROW A PROMOTIONAL 
-- MUSIC FESTIVAL IN THE CITY WE MADE THE MOST MONEY. WRITE A QUERY THAT RETURNS 
-- ONE CITY THAT HAS THE HIGHEST SUM OF INVOICE TOTALS. RETURN BOTH THE CITY NAME & 
-- SUM OF ALL INVOICES TOTAL??

SELECT SUM(total) as total_invoice, billing_city
FROM INVOICE
group by billing_city
order by total_invoice desc

-- Q5: who is the best customer ?

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id 
order by total desc
limit 1

--- 	QUESTIONS SET NO # 2 (MODERATE)

-- Q1: WRITE QUERY TO RETURN THE E_MAIL, FIRST_NAME, LAST_NAME 

SELECT DISTINCT email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in
				(select track_id from track 
				 join genre on track.genre_id = genre.genre_id
				 where genre.name like 'Rock'
				 )
order by email;

--Q2: Lets invite the artists who have written the most rock music in our dataset.

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Q3: Return all the track names that have a song length 

select name, milliseconds
from track
where milliseconds > (
					select avg(milliseconds) as avg_track_length
					from track)
order by milliseconds desc;


-- QUESSTION SET 3 (ADVANCE)

-- Q1: FIND HOW MUCH AMOUNT SPENT BY EACH CUSTOMER ON ARTISTS ?
-- WRITE A QUERY TO RETURN CUSTOMER NAME, ARTIST NAME AND TOTAL SPENT.

WITH best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales 
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1 
)
select c.customer_id, c.first_name, c.last_name ,bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i 
join customer c on c.customer_id = i.customer_id 
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;
				

-- Q2: WE WANT TO FIND OUT THE MOST POPULAR MUSIC GENRE FOR EACH COUNTRY.
-- WE DETERMINE THE MOST POPULAR GENRE AS THE GENRE WITH THE HIGHEST AMOUNT OF PURCHASES.
-- WRITE A QUERRY THAT RETURNS EACH COUNTRY ALONG WITH THE TOP GENRE. FOR COUNTRIES WHERE THE MAXIMUM
-- NUMBER OF PURCHASES IS SHARED RETURN ALL GENRES.

WITH popular_genre as 
(
	select count (invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as Row_Num
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where Row_Num<=1

-- Q3: WRITE A QUERY THAT DETERMINES THE CUSTOOMER THAT HAS SPENT THE MOST ON MUSIC FOR EACH COUNTRY.
--WRITE A QUERY THAT RETURNS THE COUNTRY ALONG WITH THE TOP CUSTOMER AND HOW MUCH THEY SPENT.
-- FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED, PROVIDE ALL CUSTOMERS WHO SPENT THIS AMOUNT.

WITH Customer_with_country as (
		select customer.customer_id, first_name,last_name,billing_country,sum(total) as total_spendin,
		row_number() over(partition by billing_country order by sum(total)desc) as Row_Num
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customer_with_country where Row_Num <= 1;
