CREATE TABLE artist (
	artist_id INTEGER PRIMARY KEY,
	name VARCHAR(255)
);

SELECT COUNT(*) FROM artist;

CREATE TABLE album (
	album_id INTEGER PRIMARY KEY,
	title VARCHAR(255),
	artist_id INTEGER REFERENCES artist(artist_id)
);

SELECT COUNT(*) FROM album;

CREATE TABLE genre (
	genre_id INTEGER PRIMARY KEY,
	name VARCHAR(120)
);

 
CREATE TABLE media_type (
	media_type_id INTEGER PRIMARY KEY,
	name VARCHAR(120)
);


SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM media_type;


CREATE TABLE track (
    track_id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    album_id INTEGER REFERENCES album(album_id),
    media_type_id INTEGER REFERENCES media_type(media_type_id),
    genre_id INTEGER REFERENCES genre(genre_id),
    composer VARCHAR(255),
    milliseconds INTEGER,
    bytes INTEGER,
    unit_price NUMERIC(10,2)
);

SELECT COUNT(*) FROM track;


SET datestyle = 'DMY';


CREATE TABLE employee (
    employee_id INTEGER PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(100),
    reports_to INTEGER,
    levels VARCHAR(10),
    birthdate TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(100)
);


SELECT COUNT(*) FROM employee;


CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(30),
    fax VARCHAR(30),
    email VARCHAR(100),
    support_rep_id INTEGER REFERENCES employee(employee_id)
);

SELECT COUNT(*) FROM customer;

CREATE TABLE invoice (
    invoice_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(customer_id),
    invoice_date TIMESTAMP,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total NUMERIC(10,2)
);

SELECT COUNT(*) FROM invoice;

 
CREATE TABLE invoice_line (
    invoice_line_id INTEGER PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoice(invoice_id),
    track_id INTEGER REFERENCES track(track_id),
    unit_price NUMERIC(10,2),
    quantity INTEGER
);
SELECT COUNT(*) 
FROM invoice_line il
LEFT JOIN invoice i ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;

SELECT COUNT(*) FROM invoice_line;




CREATE TABLE playlist (
    playlist_id INTEGER PRIMARY KEY,
    name VARCHAR(120)
);


CREATE TABLE playlist_track (
    playlist_id INTEGER REFERENCES playlist(playlist_id),
    track_id INTEGER REFERENCES track(track_id),
    PRIMARY KEY (playlist_id, track_id)
);

SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM invoice_line;
SELECT COUNT(*) FROM track;


SELECT COUNT(*)
FROM (SELECT i.invoice_id, i.total,SUM(il.unit_price * il.quantity) AS calculated_total
FROM invoice i
JOIN invoice_line il 
ON i.invoice_id = il.invoice_id
GROUP BY i.invoice_id, i.total
HAVING i.total <> SUM(il.unit_price * il.quantity)) sub;


SELECT c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,ROUND(SUM(i.total), 2) AS lifetime_spending
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY lifetime_spending DESC
LIMIT 10;


SELECT CASE 
WHEN purchase_count = 1 THEN 'One-Time'
ELSE 'Repeat'
END AS customer_type,
COUNT(*) AS customer_count
FROM (
SELECT customer_id, COUNT(*) AS purchase_count
FROM invoice
GROUP BY customer_id) sub
GROUP BY customer_type;



SELECT MIN(purchase_count),MAX(purchase_count)
FROM (SELECT customer_id, COUNT(*) AS purchase_count
FROM invoice
GROUP BY customer_id) sub;


SELECT COUNT(DISTINCT customer_id) FROM customer;

SELECT COUNT(DISTINCT customer_id) FROM invoice;



/*  Section 1 — Customer Analytics 

1.1.Which customers have spent the most money on music? */

SELECT c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,ROUND(SUM(i.total), 2) AS lifetime_spending,
RANK() OVER (ORDER BY SUM(i.total) DESC) AS spending_rank
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY spending_rank
LIMIT 10;


/* 1.2.What is the average customer lifetime value? */

SELECT ROUND(AVG(lifetime_spending), 2) AS avg_customer_lifetime_value
FROM (SELECT customer_id, SUM(total) AS lifetime_spending
FROM invoice
GROUP BY customer_id) sub;


/* 1.3. How many customers have made repeat purchases vs one-time purchases? */ 

SELECT 
CASE WHEN purchase_count = 1 THEN 'One-Time'ELSE 'Repeat'END AS customer_type,
COUNT(*) AS customer_count
FROM ( SELECT customer_id, COUNT(*) AS purchase_count
FROM invoice
GROUP BY customer_id
) sub
GROUP BY customer_type;

/* 1.4. Which country generates the most revenue per customer? */

SELECT c.country,ROUND(SUM(i.total), 2) AS total_revenue,
COUNT(DISTINCT c.customer_id) AS customer_count,ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer DESC;

/* 1.5. Which customers haven't made a purchase in the last 6 months? */

SELECT c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,MAX(i.invoice_date) AS last_purchase
FROM customer c
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
HAVING MAX(i.invoice_date) < (SELECT MAX(invoice_date) FROM invoice) - INTERVAL '6 months';





/* Section 2 - Sales & Revenue Analysis

2.1.What are the monthly revenue trends for the last two years? */

SELECT MIN(invoice_date), MAX(invoice_date)
FROM invoice;

/* Monthly Revenue */

SELECT DATE_TRUNC('month', invoice_date) AS month,ROUND(SUM(total), 2) AS monthly_revenue
FROM invoice
WHERE invoice_date >= (SELECT MAX(invoice_date) FROM invoice) - INTERVAL '2 years'
GROUP BY month
ORDER BY month;


/* 2.2. What is the average value of an invoice (purchase)? */

SELECT ROUND(AVG(total), 2) AS avg_invoice_value
FROM invoice;



/* 2.3. Which payment methods are used most frequently? */

"Payment method analysis is not possible due to absence of payment method data in the dataset."



/* 2.4. How much revenue does each sales representative contribute? */

SELECT e.employee_id,e.first_name || ' ' || e.last_name AS employee_name,ROUND(SUM(i.total), 2) AS revenue_generated
FROM employee e
JOIN customer c 
ON e.employee_id = c.support_rep_id
JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY e.employee_id, employee_name
ORDER BY revenue_generated DESC;



/* 2.5. Which months or quarters have peak music sales? */

/* Monthly peak */
SELECT DATE_PART('month', invoice_date) AS month_number,ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY month_number
ORDER BY revenue DESC;

/* Quarterly peak */
SELECT DATE_PART('quarter', invoice_date) AS quarter,ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY quarter
ORDER BY revenue DESC;



/* Sales & Revenue Insights:

1. Revenue shows moderate month-to-month fluctuations with no consistent upward growth trend.

2. Average invoice value (7.67) indicates micro-transaction purchasing behavior.

3. Sales representative contributions are relatively evenly distributed, reducing operational concentration risk.

4. Q1 consistently generates the highest revenue, while Q4 is the weakest quarter.

5. March is the strongest revenue month, suggesting early-year purchasing momentum. */



/*  Section 3 — Product & Content Analysis */


/* 3.1. Which tracks generated the most revenue? */
SELECT t.track_id,t.name AS track_name,ROUND(SUM(il.unit_price * il.quantity), 2) AS track_revenue
FROM track t
JOIN invoice_line il 
ON t.track_id = il.track_id
GROUP BY t.track_id, track_name
ORDER BY track_revenue DESC
LIMIT 10;



/* 3.2. Which albums are most frequently included in purchases? */
SELECT a.album_id,a.title AS album_title,
COUNT(il.invoice_line_id) AS times_purchased
FROM album a
JOIN track t 
ON a.album_id = t.album_id
JOIN invoice_line il 
ON t.track_id = il.track_id
GROUP BY a.album_id, album_title
ORDER BY times_purchased DESC
LIMIT 10;

/* 3.3. Which playlists contain the most purchased tracks? */
SELECT p.playlist_id,p.name AS playlist_name,
COUNT(DISTINCT il.track_id) AS purchased_tracks_in_playlist
FROM playlist p
JOIN playlist_track pt 
ON p.playlist_id = pt.playlist_id
JOIN invoice_line il 
ON pt.track_id = il.track_id
GROUP BY p.playlist_id, playlist_name
ORDER BY purchased_tracks_in_playlist DESC
LIMIT 10;


/* 3.4. Are there any tracks or albums that have never been purchased? */
SELECT t.track_id,t.name
FROM track t
LEFT JOIN invoice_line il 
ON t.track_id = il.track_id
WHERE il.track_id IS NULL;


SELECT COUNT(*)
FROM track t
LEFT JOIN invoice_line il 
    ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

/* Albums */
SELECT a.album_id, a.title
FROM album a
WHERE NOT EXISTS (SELECT 1 FROM track t
JOIN invoice_line il 
ON t.track_id = il.track_id
WHERE t.album_id = a.album_id);

/* Product & Content Insights:

1. Revenue is highly concentrated in a small number of tracks.

2. “War Pigs” significantly outperforms other tracks.

3. Album-level purchases show similar concentration patterns.

4. 1697 tracks have never been purchased — indicating substantial dead inventory.

5. The catalog follows a strong long-tail distribution model. 
*/



/* Is revenue concentrated in a few genres or evenly spread? */
SELECT g.name AS genre,ROUND(SUM(il.unit_price * il.quantity), 2) AS genre_revenue
FROM genre g
JOIN track t 
ON g.genre_id = t.genre_id
JOIN invoice_line il 
ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY genre_revenue DESC;

/*
Rock → 2608.65
Metal → 612.81
Alternative & Punk → 487.08

Rock is not just leading. It’s dominating.
Rock alone generates more revenue than Metal + Alternative & Punk combined.
*/

SELECT 
ROUND(SUM(CASE WHEN g.name = 'Rock' THEN il.unit_price * il.quantity END) * 100.0/ SUM(il.unit_price * il.quantity),2) AS rock_revenue_percent
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id;

/* Strategic Interpretation:

• The store is effectively a Rock-driven business.
• Metal and Alternative are secondary pillars.
• Most other genres are long-tail contributors.
• Inventory diversification does not equal revenue diversification.

*/


SELECT g.name AS genre,
COUNT(t.track_id) AS track_count
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY track_count DESC;

 

/*
Rock has the largest inventory AND the highest revenue.
Latin has 579 tracks but only ~165 revenue.
Metal has 374 tracks but ~613 revenue.
*/


SELECT g.name AS genre,COUNT(t.track_id) AS track_count,ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue,
ROUND(SUM(il.unit_price * il.quantity) / COUNT(t.track_id),2) AS revenue_per_track
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY revenue_per_track DESC;



SELECT g.name AS genre,ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue,
ROUND(SUM(il.unit_price * il.quantity) * 100.0 / SUM(SUM(il.unit_price * il.quantity)) OVER (),2) AS revenue_percent
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY revenue_percent DESC;

/*
Strategic Insight and Implications:

• Rock drives volume.
• Easy Listening and Electronic/Dance are high-yield per asset.
• Latin is severely underperforming (627 tracks → 0.26 per track).
• TV Shows and Drama are nearly dead monetization categories.


1. Revenue risk is genre-concentrated.
If Rock demand drops, revenue collapses.

2. Inventory is inefficient.
Large portions of catalog contribute almost nothing.

3. There is opportunity in high-efficiency genres like Easy Listening and Electronic/Dance.
They don’t drive volume, but they monetize well per asset.

4. Underperforming genres (Latin, TV Shows, Drama) need reevaluation.
Either better marketing or reduced catalog investment.
*/


/* Section 4 — Artist & Genre Performance 
4.1. Who are the top 5 highest-grossing artists?
*/
SELECT ar.artist_id,ar.name AS artist_name,ROUND(SUM(il.unit_price * il.quantity), 2) AS artist_revenue
FROM artist ar
JOIN album a ON ar.artist_id = a.artist_id
JOIN track t ON a.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id, artist_name
ORDER BY artist_revenue DESC
LIMIT 5;


/* 4.2. Which genres are most popular in terms of number of tracks sold? */
SELECT g.name AS genre,SUM(il.quantity) AS tracks_sold
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY tracks_sold DESC;


/* 4.3. Are certain genres more popular in specific countries? */
SELECT c.country,g.name AS genre,
SUM(il.quantity) AS tracks_sold
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, tracks_sold DESC;


/* The Top Genre per Country */

WITH country_genre_sales AS (
SELECT c.country,g.name AS genre,SUM(il.quantity) AS tracks_sold
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name)
SELECT * FROM (SELECT *,RANK() OVER (PARTITION BY country ORDER BY tracks_sold DESC) AS rnk
FROM country_genre_sales) sub
WHERE rnk = 1
ORDER BY tracks_sold DESC;


/* 
Interpretation:

• Rock is universally preferred across markets.
• No country shows a fundamentally different taste profile.
• Localization strategy may not need drastic genre differentiation.
• Marketing can safely lean into Rock globally.

Artist & Genre Performance Insights:

1. Revenue is highly concentrated among Rock artists.

2. Top 5 artists are all Rock-based.

3. Rock dominates both revenue and units sold.

4. Rock is the top genre in nearly every country.

5. Revenue hierarchy is volume-driven rather than price-driven.
*/


/*  Section 5 — Employee & Operational Efficiency */

/* Which employees (support representatives) are managing the highest-spending customers? */

WITH customer_ltv AS (
SELECT c.customer_id,c.support_rep_id,SUM(i.total) AS lifetime_spending
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.support_rep_id)
SELECT e.employee_id,e.first_name || ' ' || e.last_name AS employee_name,
ROUND(SUM(cl.lifetime_spending),2) AS total_managed_revenue
FROM employee e
JOIN customer_ltv cl 
ON e.employee_id = cl.support_rep_id
GROUP BY e.employee_id, employee_name
ORDER BY total_managed_revenue DESC;

/* 
Revenue Managed per Employee

Jane Peacock → 1731.51
Margaret Park → 1584.00
Steve Johnson → 1393.92

Observation:

- Revenue distribution across employees is relatively balanced.
- Difference between top and bottom ≈ 337.59.

Insight:

• No single rep is disproportionately carrying the business.
• Revenue distribution appears operationally stable.
• Customer allocation is reasonably balanced. */


/*  5.2 What is the average number of customers per employee? */ 
SELECT ROUND(AVG(customer_count),2) AS avg_customers_per_employee
FROM (SELECT support_rep_id,COUNT(*) AS customer_count
FROM customer
GROUP BY support_rep_id) sub;

/*
19.67 customers per rep.

That means roughly:

~20 customers per support representative.

Interpretation:

• Manageable portfolio size.
• Not overloaded.
• Capacity likely exists for growth.

*/

/* 5.3 Which employee regions bring in the most revenue? */
SELECT e.country AS employee_country,ROUND(SUM(i.total),2) AS revenue_generated
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.country
ORDER BY revenue_generated DESC;
/*
Canada → 4709.43

And that’s the only region listed.

Because all employees are in Canada.

Important Insight:

Revenue geography (customer countries) ≠ operational geography.

Customers are global.
Support staff is centralized.

This is a centralized service model.

Strategic Implication:

• Lower operational complexity.
• Potential time zone constraints.
• Opportunity to localize support if global revenue grows significantly.
*/

/*  Section 6 — Geographic Trends  */
/* 6.1 Which countries have the highest number of customers? */

SELECT country,COUNT(*) AS customer_count
FROM customer
GROUP BY country
ORDER BY customer_count DESC;

/* 
Insight:

- Customer base is geographically diversified, but heavily skewed toward USA.
- USA has the largest market share by customers.
- No single country dominates overwhelmingly — this is moderate concentration. */


/* 6.2 How does revenue vary by region? */
SELECT c.country,ROUND(SUM(i.total),2) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

/* 
Ranking aligns roughly with customer count.

That means:
- Revenue is volume-driven geographically as well.
- More customers → more revenue.
 */

/* 6.3 Are there underserved geographic regions (high users, low sales)? */
WITH country_stats AS (SELECT c.country,
COUNT(DISTINCT c.customer_id) AS customers,SUM(i.total) AS revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country)
SELECT country,customers,ROUND(revenue,2) AS revenue,ROUND(revenue / customers,2) AS revenue_per_customer
FROM country_stats
ORDER BY customers DESC;
/*
Czech Republic has only 2 customers — but extremely high spending per customer.
- This is a high-value micro-market.
- India and Portugal also punch above their weight.
- USA has the most customers but moderate per-customer value.

This tells us:
- USA = scale market
- Czech Republic = high-intensity market */

/*  Section 7 — Customer Retention & Purchase Patterns 
7.1 Distribution of purchase frequency per customer */

SELECT purchase_count,COUNT(*) AS number_of_customers
FROM (SELECT customer_id, COUNT(*) AS purchase_count 
FROM invoice
GROUP BY customer_id) sub
GROUP BY purchase_count
ORDER BY purchase_count;

/*
Interpretation:

• Customers are not one-time buyers.
• The platform does not rely on casual transactions.
• It has consistent repeat behavior.
*/



/*  7.2 Average time between purchases */
WITH purchase_gaps AS (
SELECT customer_id,invoice_date,
LAG(invoice_date) OVER (PARTITION BY customer_id 
ORDER BY invoice_date) AS prev_date
FROM invoice)
SELECT ROUND(
AVG(EXTRACT(EPOCH FROM (invoice_date - prev_date)) / 86400),2) AS avg_days_between_purchases
FROM purchase_gaps
WHERE prev_date IS NOT NULL;

/*
Interpretation:

• Customers return 2–3 times per year.
• This is considered moderate retention.
• Not subscription-like behavior.
• Not high-frequency consumption.
*/


/*  7.3 Percentage of customers purchasing multiple genres */
WITH customer_genre_count AS (
SELECT c.customer_id,COUNT(DISTINCT g.genre_id) AS genre_count
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id)
SELECT ROUND(COUNT(*) FILTER (WHERE genre_count > 1) * 100.0 / COUNT(*),2) AS multi_genre_percent
FROM customer_genre_count;

/*
This means:
• Cross-sell potential already exists.
• Customers are not genre-locked.
• Recommendation engine likely influences diversification.
*/


/*  Section 8 — Operational Optimization */
/*  8.1 Most common combinations of tracks purchased together */
SELECT t1.name AS track_1,t2.name AS track_2,
COUNT(*) AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2 
ON il1.invoice_id = il2.invoice_id
AND il1.track_id < il2.track_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
GROUP BY track_1, track_2
ORDER BY times_bought_together DESC
LIMIT 10;

/*
Observation:
- These are same-artist purchases.
- Customers buying one track from an artist tend to buy multiple tracks from that same artist in the same invoice.
*/


/*  8.2 Are there pricing patterns that lead to higher or lower sales? */
SELECT t.unit_price,SUM(il.quantity) AS total_units_sold
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.unit_price
ORDER BY t.unit_price;

/*
Interpretation:

• Customers overwhelmingly purchase at 0.99.
• Higher-priced tracks almost never sell.
• Revenue is driven by volume at standardized pricing.
*/


/*  8.3 Which media types are declining or increasing? */
SELECT mt.name AS media_type,DATE_TRUNC('year', i.invoice_date) AS year,
SUM(il.quantity) AS units_sold
FROM media_type mt
JOIN track t ON mt.media_type_id = t.media_type_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY media_type, year
ORDER BY media_type, year;


/*
Interpretation:

• MPEG audio file dominates the ecosystem.
• No major declining trend.
• No strong growth signals either — stable plateau.
*/




























































































