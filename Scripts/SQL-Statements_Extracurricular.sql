/*** LIMIT */
SELECT occurred_at, account_id, channel
FROM web_events
LIMIT 15;

/*** ORDER BY

   return the 10 earliest orders in the orders table */
SELECT id, occurred_at, total_amt_usd
  FROM orders
  ORDER BY occurred_at
  LIMIT 10;

/* return the top 5 orders in terms of largest total_amt_usd */
SELECT id, occurred_at, total_amt_usd
  FROM orders
  ORDER BY total_amt_usd DESC
  LIMIT 5;

/* return the lowest 20 orders in terms of smallest total_amt_usd */
SELECT id, occurred_at, total_amt_usd
  FROM orders
  ORDER BY total_amt_usd
  LIMIT 20;

/* order ID, account ID, and total dollar amount for all the orders,
   sorted first by the account ID (in ascending order),
   and then by the total dollar amount (in descending order) */
SELECT id, account_id, total_amt_usd
  FROM orders
  ORDER BY account_id, total_amt_usd DESC;

/* order ID, account ID, and total dollar amount for each order,
   sorted first by total dollar amount (in descending order),
   and then by account ID (in ascending order) */
SELECT id, account_id, total_amt_usd
  FROM orders
  ORDER BY total_amt_usd DESC, account_id;

/*** WHERE

   first 5 rows and all columns from the orders table that have
   a dollar amount of gloss_amt_usd greater than or equal to 1000*/
SELECT *
  FROM orders
  WHERE gloss_amt_usd >= 1000
  LIMIT 5;

/* first 10 rows and all columns from the orders table that have
   a total_amt_usd less than 500 */
SELECT *
FROM orders
  WHERE total_amt_usd < 500
  LIMIT 10;

/* Filter the accounts table to include the company name, website,
   and the primary point of contact (primary_poc) just for
   the Exxon Mobil company in the accounts table. */
SELECT name, website, primary_poc
  FROM accounts
  WHERE name = 'Exxon Mobil';

/*** Derived Columns

   Create a column that divides the standard_amt_usd by the standard_qty
   to find the unit price for standard paper for each order.
   Limit the results to the first 10 orders, and include the id and account_id fields. */
SELECT id, account_id, standard_amt_usd/standard_qty AS unit_price
  FROM orders
  LIMIT 10;

/* Find the percentage of revenue that comes from poster paper for each order.
   Use only the columns that end with _usd (without using the total column).
   Display the id and account_id fields also. */
SELECT id, account_id, poster_amt_usd/(standard_amt_usd+gloss_amt_usd+poster_amt_usd) AS poster_percent
FROM orders
LIMIT 10;

/*** LIKE

  all the companies whose names start with 'C'. */
SELECT name
  FROM accounts
  WHERE name LIKE 'C%';

/* all companies whose names contain the string 'one' somewhere in the name. */
SELECT name
  FROM accounts
  WHERE name LIKE '%one%';

/* all companies whose names end with 's'. */
SELECT name
  FROM accounts
  WHERE name LIKE '%s';

/*** IN

  Use the accounts table to find the account name, primary_poc, and sales_rep_id
  for Walmart, Target, and Nordstrom. */
SELECT name, primary_poc, sales_rep_id
  FROM accounts
  WHERE name IN ('Walmart', 'Target', 'Nordstrom');

/* Use the web_events table to find all information regarding individuals
   who were contacted via the channel of organic or adwords. */
SELECT *
  FROM web_events
  WHERE channel IN ('organic', 'adwords');

/*** BETWEEN

  Orders where the standard_qty is over 1000, the poster_qty is 0, and the gloss_qty is 0. */
SELECT *
  FROM orders
  WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

/* Using the accounts table, find all the companies whose names do not start with 'C' and end with 's'. */
SELECT name
  FROM accounts
  WHERE name NOT LIKE 'C%' and name LIKE '%s';

/* Order date and gloss_qty data for all orders where gloss_qty is between 24 and 29 */
SELECT occurred_at, gloss_qty
  FROM orders
  WHERE gloss_qty BETWEEN 24 AND 29;

/* Use the web_events table to find all information regarding individuals
   who were contacted via the organic or adwords channels, and started their account
   at any point in 2016, sorted from newest to oldest.
   ACHTUNG! The endpoint for the date is the next day because the time is 00:00:00. */
SELECT *
  FROM web_events
  WHERE
    channel IN ('organic', 'adwords') AND
    occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
  ORDER BY occurred_at DESC;

/*** OR

  Order ids where either gloss_qty or poster_qty is greater than 4000. */
SELECT id
  FROM orders
  WHERE gloss_qty > 4000 or poster_qty > 4000;

/* Orders where the standard_qty is zero and either the gloss_qty or poster_qty is over 1000. */
SELECT id
  FROM orders
  WHERE
    standard_qty = 0 AND
    (gloss_qty > 1000 OR poster_qty > 1000);

/* Company names that start with a C or W, and the primary contact
   contains ana or Ana, but it does not contain eana. */
SELECT name, primary_poc
  FROM accounts
  WHERE
    (name LIKE 'C%' OR name LIKE 'W%') AND
    (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND
    primary_poc NOT LIKE '%eana%';

/*** JOIN

  all data from the accounts and orders tables. */
SELECT orders.*, accounts.*
  FROM orders
  JOIN accounts
  ON orders.account_id = accounts.id;

/* standard_qty, gloss_qty, and poster_qty from the orders table,
   and website and  primary_poc from the accounts table. */
SELECT orders.standard_qty, orders.poster_qty, accounts.website, accounts.primary_poc
  FROM orders
  JOIN accounts
  ON orders.account_id = accounts.id;

/*** Aliases

  all web_events associated with account name of Walmart:
  primary_poc, time of the event, the channel for each event, and account name (i.e., Walmart). */
SELECT acc.primary_poc, we.occurred_at, we.channel, acc.name
  FROM accounts acc
  JOIN web_events we
  ON acc.id = we.account_id
  WHERE acc.name = 'Walmart';

/* Region for each sales_rep along with their associated accounts sorted alphabetically:
   region name, sales rep name, and account name. */
SELECT reg.name Region, sr.name Sales, acc.name Account
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  ORDER BY acc.name;

/* Name for each region for every order, account name, and unit price (total_amt_usd/total).
   A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero. */
SELECT reg.name Region, acc.name Account, (ord.total_amt_usd/(ord.total + 0.01)) Price
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id;

/*** LEFT & RIGHT JOIN

   Region for each sales_rep along with their associated accounts for the Midwest region:
   region name, sales rep name, and account name, sorted alphabetically according to account name. */
SELECT reg.name region_name, sr.name sales_rep_name, acc.name account_name
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE reg.name = 'Midwest'
  ORDER BY acc.name;

/* Same as above, but where the sales rep has a first name starting with S. */
SELECT reg.name region_name, sr.name sales_rep_name, acc.name account_name
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE reg.name = 'Midwest' AND sr.name LIKE 'S%'
  ORDER BY acc.name;

/* Same as above, but where the sales rep has a last name starting with K. */
SELECT reg.name region_name, sr.name sales_rep_name, acc.name account_name
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE reg.name = 'Midwest' AND sr.name LIKE '% K%'
  ORDER BY acc.name;

/* Name for each region for every order, account name, and unit price (total_amt_usd/total + 0.01),
   only for if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. */
SELECT reg.name Region, acc.name Account, (ord.total_amt_usd/(ord.total + 0.01)) Price
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE standard_qty > 100;

/* Same as above, adding the poster order quantity exceeds 50 and sorting by smalles unit price first. */
SELECT reg.name Region, acc.name Account, (ord.total_amt_usd/(ord.total + 0.01)) Price
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE standard_qty > 100 AND poster_qty > 50
  ORDER BY Price;

/* Same as above, but sorting by larges unit price first. */
SELECT reg.name Region, acc.name Account, (ord.total_amt_usd/(ord.total + 0.01)) Price
  FROM accounts acc
  JOIN sales_reps sr
  ON acc.sales_rep_id = sr.id
  JOIN region reg
  ON sr.region_id = reg.id
  JOIN orders ord
  ON ord.account_id = acc.id
  WHERE standard_qty > 100 AND poster_qty > 50
  ORDER BY Price DESC;

/* Channels used by account id 1001: account name and the different channels.
   SELECT DISTINCT narrows down the results to only the unique values. */
SELECT DISTINCT acc.name account_name, we.channel
  FROM accounts acc
  JOIN web_events we
  ON acc.id = we.account_id
  WHERE acc.id = 1001;

/* Orders that occurred in 2015: occurred_at, account name, order total, and order total_amt_usd. */
SELECT ord.occurred_at, acc.name, ord.total, ord.total_amt_usd
  FROM accounts acc
  JOIN orders ord
  ON acc.id = ord.account_id
  WHERE ord.occurred_at BETWEEN '2015-01-01' and '2016-01-01'
  ORDER BY ord.occurred_at DESC;

/*** SUM

   Total amount of poster_qty paper ordered in the orders table. */
SELECT SUM(poster_qty)
  FROM orders;

/* Total amount of standard_qty paper ordered in the orders table. */
SELECT SUM(standard_qty)
  FROM orders;

/* Total dollar amount of sales using the total_amt_usd in the orders table. */
SELECT SUM(total_amt_usd)
  FROM orders;

/* Total amount spent on standard_amt_usd and gloss_amt_usd paper for each order (no aggregate) in the orders table. */
SELECT standard_amt_usd + gloss_amt_usd AS amount
  FROM orders;

/* Standard_amt_usd per unit of standard_qty paper, using both an aggregation and a mathematical operator. */
SELECT SUM(standard_amt_usd) / SUM(standard_qty) unit_price
  FROM orders;

/*** MIN, MAX, and AVG

   When was the earliest order ever placed? */
SELECT MIN(occurred_at)
  FROM orders;

/* Same as above without using an aggregation function. */
SELECT occurred_at
  FROM orders
  ORDER BY occurred_at
  LIMIT 1;

/* When did the most recent (latest) web_event occur? */
SELECT MAX(occurred_at)
  FROM web_events;

/* Same as above without using an aggregation function. */
SELECT occurred_at
  FROM web_events
  ORDER BY occurred_at DESC
  LIMIT 1;

/* Mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount
   of each paper type purchased per order:  6 values - one for each paper type
   for the average number of sales, as well as the average amount. */
SELECT AVG(standard_amt_usd) st_usd, AVG(gloss_amt_usd) gl_usd, AVG(poster_amt_usd) po_usd,
       AVG(standard_qty) st_qty, AVG(gloss_qty) gl_qty, AVG(poster_qty) po_qty
  FROM orders;

/* MEDIAN total_usd spent on all orders? */
SELECT *
  FROM (SELECT total_amt_usd
        FROM orders
        ORDER BY total_amt_usd
        LIMIT 3457) AS Table1
  ORDER BY total_amt_usd DESC
  LIMIT 2;

/*** GROUP BY

   Which account (by name) placed the earliest order? (account name and order date). */
SELECT a.name account, o.occurred_at orddate
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  ORDER BY orddate
  LIMIT 1;

/* Total sales in usd for each account: total sales for each company-s orders in usd and company name. */
SELECT a.name account, SUM(o.total_amt_usd) sales
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY sales DESC;

/* Via what channel did the most recent (latest) web_event occur,
   which account was associated with this web_event? (date, channel, and account name). */
SELECT we.occurred_at we_date, we.channel channel, a.name account
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id
  ORDER BY we_date DESC
  LIMIT 1;

/* Total number of times each type of channel from the web_events was used. */
SELECT we.channel channel, COUNT(*) times
FROM web_events we
GROUP BY we.channel
ORDER BY times DESC;

/* Primary contact associated with the earliest web_event. */
SELECT a.primary_poc contact, we.occurred_at wedate
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id
  ORDER BY wedate
  LIMIT 1;

/* Smallest order placed by each account in terms of total usd: account name and total usd (smallest to largest). */
SELECT a.name account, MIN(o.total_amt_usd) sales
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY sales;

/* Number of sales reps in each region: region and the number of sales_reps (from fewest reps to most). */
SELECT r.name reg, COUNT(*) num_reps
  FROM region r
  JOIN sales_reps sr
  ON r.id = sr.region_id
  GROUP BY r.name
  ORDER BY num_reps;

/*** Multiple GROUP BYs

   For each account, the average amount of each type of paper purchased across their orders:
   account name, average quantity purchased for each of the paper types. */
SELECT a.name account_name, AVG(o.standard_qty) s_qty, AVG(o.gloss_qty) g_qty, AVG(o.poster_qty) p_qty
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY a.name;

/* For each account, the average amount spent per order on each paper type:
   account name, average amount spent on each paper type. */
SELECT a.name account_name, AVG(o.standard_amt_usd) s_amt_usd, AVG(o.gloss_amt_usd) g_amt_usd, AVG(o.poster_amt_usd) p_amt_usd
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY a.name;

/* Number of times a particular channel was used in the web_events table for each sales rep:
   name of the sales rep, channel, number of occurrences (highest number of occurrences first). */
SELECT sr.name rep, we.channel channel, COUNT(*) num
  FROM web_events we
  JOIN accounts a
  ON we.account_id = a.id
  JOIN sales_reps sr
  ON sr.id = a.sales_rep_id
  GROUP BY rep, channel
  ORDER BY num DESC;

/* Number of times a particular channel was used in the web_events table for each region:
   region name, channel, number of occurrences (highest number of occurrences first). */
SELECT r.name reg, we.channel channel, COUNT(*) num
  FROM web_events we
  JOIN accounts a
  ON we.account_id = a.id
  JOIN sales_reps sr
  ON sr.id = a.sales_rep_id
  JOIN region r
  ON r.id = sr.region_id
  GROUP BY reg, channel
  ORDER BY num DESC;

/*** DISTINCT

   Are there any accounts associated with more than one region?
   The 1st query returns the same number as results as the 2nd
   => every account is associated with only 1 region */
SELECT a.name account, r.name reg
  FROM accounts a
  JOIN sales_reps sr
  ON a.sales_rep_id = sr.id
  JOIN region r
  ON r.id = sr.region_id;

SELECT DISTINCT name
  FROM accounts;

/* Have any sales reps worked on more than one account? */
SELECT sr.name rep, COUNT(*) num_accounts
  FROM accounts a
  JOIN sales_reps sr
  ON sr.id = a.sales_rep_id
  GROUP BY sr.name
  ORDER BY num_accounts;

/*** HAVING

   How many of the sales reps have more than 5 accounts that they manage? */
SELECT sr.name rep, COUNT(*) num
  FROM accounts a
  JOIN sales_reps sr
  ON a.sales_rep_id = sr.id
  GROUP BY rep
  HAVING COUNT(a.id) > 5
  ORDER BY num DESC;

/* How many accounts have more than 20 orders? */
SELECT COUNT(*) "over 20 orders"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  HAVING COUNT(o.id) > 20;

/* Which account has the most orders? */
SELECT a.name "most orders", COUNT(*) "number orders"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY "number orders" DESC
  LIMIT 1;

/* Which accounts spent more than 30,000 usd total across all orders? */
SELECT a.name "big spender", SUM(o.total_amt_usd) "total amount"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  HAVING SUM(o.total_amt_usd) > 30000
  ORDER BY "total amount" DESC;

/* Which accounts spent less than 1,000 usd total across all orders? */
SELECT a.name "little spender", SUM(o.total_amt_usd) "total amount"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  HAVING SUM(o.total_amt_usd) < 1000
  ORDER BY "total amount" DESC;

/* Which account has spent the most with us? */
SELECT a.name "big spender", SUM(o.total_amt_usd) "total amount"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY "total amount" DESC
  LIMIT 1;

/* Which account has spent the least with us? */
SELECT a.name "little spender", SUM(o.total_amt_usd) "total amount"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY a.name
  ORDER BY "total amount"
  LIMIT 1;

/* Which accounts used facebook as a channel to contact customers more than 6 times? */
SELECT a.name "Facebook user", COUNT(*) "total"
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id
  GROUP BY a.name, we.channel
  HAVING COUNT(*) > 6 AND we.channel = 'facebook'
  ORDER BY "total" DESC;

/* Which account used facebook most as a channel? */
SELECT a.name "Facebook user", COUNT(*) "total"
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id
  GROUP BY a.name, we.channel
  HAVING we.channel = 'facebook'
  ORDER BY COUNT(*) DESC
  LIMIT 1;

/* Which channel was most frequently used by most accounts? */
SELECT we.channel "Channel", COUNT(*) "Times used", a.name "Account"
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id
  GROUP BY we.channel, a.name
  ORDER BY "Times used" DESC
  LIMIT 10;

/*** DATE

   Sales in terms of total dollars for all orders in each year, ordered from greatest to least. */
SELECT SUM(total_amt_usd) "Yearly Total", DATE_PART('year', occurred_at) "Year"
  FROM orders
  GROUP BY 2
  ORDER BY 1 DESC;

/* Which month did Parch & Posey have the greatest sales in terms of total dollars?
   Are all months evenly represented by the dataset?
   NO, ONLY 1 MONTH OF SALES EACH, SO WE REMOVE THEM FROM OUR QUERY BELOW: */
SELECT SUM(total_amt_usd) "Monthly Total", DATE_PART('month', occurred_at) "Month"
  FROM orders
  WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
  GROUP BY 2
  ORDER BY 1 DESC;

/* Which year did Parch & Posey have the greatest sales in terms of total number of orders?
   Are all years evenly represented by the dataset? NO, NOT 2013 AND 2017 */
SELECT COUNT(*) "Yearly Total", DATE_PART('year', occurred_at) "Year"
  FROM orders
  GROUP BY 2
  ORDER BY 1 DESC;

/* Which month did Parch & Posey have the greatest sales in terms of total number of orders?
   Are all months evenly represented by the dataset? NO, WE REMOVED 2013 AND 2017 AS ABOVE. */
SELECT COUNT(*) "Monthly Total", DATE_PART('month', occurred_at) "Month"
  FROM orders
  WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
  GROUP BY 2
  ORDER BY 1 DESC;

/* In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
   ACHTUNG! WHERE is used here because it filters a non-aggregate column (otherwise HAVING would have been required) */
SELECT SUM(o.gloss_amt_usd) "Monthly Total", DATE_TRUNC('month', o.occurred_at) "Year & Month"
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  WHERE a.name = 'Walmart'
  GROUP BY 2
  ORDER BY 1 DESC
  LIMIT 1;

/*** CASE

   Display for each order, the account ID, total amount of the order, and the level of the order
   - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000. */
SELECT o.id "Order",
       a.id "Account",
       o.total_amt_usd "$ Total",
       CASE WHEN o.total_amt_usd >= 3000 THEN 'Large'
            ELSE 'Small' END AS "Order Size"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id;

/* Number of orders in each of three categories, based on the 'total' amount of each order:
   'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'. */
SELECT id "Order",
       total_amt_usd "$ Total",
       CASE WHEN total_amt_usd >= 2000 THEN 'At Least 2000'
            WHEN total_amt_usd < 1000 THEN 'Less than 1000'
            ELSE 'Between 1000 and 2000' END AS "Category"
  FROM orders;

/* 3 different levels of customers based on the amount associated with their purchases (total sales of all orders):
   Lifetime Value greater than 200,000 usd, between 200,000 and 100,000 usd, and under 100,000 usd.
   Account name, total sales of all orders for the customer, and level associated. Top spending customers listed first. */
SELECT a.name "Customer",
       SUM(o.total_amt_usd) "$ Total",
       CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN '>= 200k'
            WHEN SUM(o.total_amt_usd) < 100000 THEN '< 100k'
            ELSE 'Between 100k and 200k' END AS "Level"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC;

/* Similar calculation: total amount spent by customers only in 2016 and 2017 (same levels as above). Top spending customers listed first. */
SELECT a.name "Customer",
       SUM(o.total_amt_usd) "$ Total",
       CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN '>= 200k'
            WHEN SUM(o.total_amt_usd) < 100000 THEN '< 100k'
            ELSE 'Between 100k and 200k' END AS "Level"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  WHERE o.occurred_at BETWEEN '2016-01-01' AND '2018-01-01'
  GROUP BY 1
  ORDER BY 2 DESC;

/* Top performing sales reps associated with more than 200 orders:
   sales rep name, total number of orders, and top or not depending on the condition above. Top sales people first. */
SELECT sr.name "Sales Rep",
       COUNT(*) "Total Orders",
       CASE WHEN COUNT(*) >= 200 THEN 'Top'
            ELSE 'Not' END AS "Performer"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  JOIN sales_reps sr
  ON sr.id = a.sales_rep_id
  GROUP BY sr.name;

/* The previous didn-t account for the middle, nor the dollar amount associated with the sales.
   Management decides they want to see these characteristics represented as well.
   Identify top performing sales reps, associated with more than 200 orders or more than 750000 in total sales.
   Middle group: any rep with more than 150 orders or 500000 in sales.
   Sales rep name,  total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria.
   Top sales people based on dollar amount of sales first. */
SELECT sr.name "Sales Rep",
       COUNT(*) "Total Orders",
       SUM(o.total_amt_usd) "Total Sales",
       CASE WHEN COUNT(*) >= 200 OR SUM(o.total_amt_usd) >= 750000 THEN 'Top'
            WHEN COUNT(*) >= 150 OR SUM(o.total_amt_usd) >= 50000 THEN 'Middle'
            ELSE 'Low' END AS "Performer"
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  JOIN sales_reps sr
  ON sr.id = a.sales_rep_id
  GROUP BY 1;

/*** Subqueries

   1st query: number of events that occur each day for each channel */
SELECT DATE_TRUNC('day', occurred_at) "Day",
       channel "Channel",
       COUNT(*) "/* Events"
  FROM web_events
  GROUP BY 1, 2
  ORDER BY 3 DESC;

/* Subquery that provides all of the data from the 1st query */
SELECT *
  FROM (SELECT DATE_TRUNC('day', occurred_at) AS day,
               channel,
               COUNT(*) num_events
          FROM web_events
          GROUP BY 1, 2
          ORDER BY 3 DESC) subquery;

/* Average number of events for each channel */
SELECT channel,
       AVG(num_events) average_events
  FROM (SELECT DATE_TRUNC('day', occurred_at) AS day,
               channel,
               COUNT(*) num_events
        FROM web_events
        GROUP BY 1, 2) subquery
        GROUP BY 1
  ORDER BY 2 DESC;

/* Month of the 1st order ever placed */
SELECT DATE_TRUNC('month', MIN(occurred_at)) first_order_month
  FROM orders;

/* Orders that took place in the same month as the 1st order */
SELECT id "Order", DATE_TRUNC('month', occurred_at) "Year/Month"
  FROM orders
  WHERE (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
           FROM orders) = DATE_TRUNC('month', occurred_at)
  ORDER BY 2;

/* Average amounts of standard, gloss, and poster paper placed in the orders that month,
   and total amount spent */
SELECT
  AVG(standard_qty) std,
  AVG(gloss_qty) gl,
  AVG(poster_qty) pos,
  SUM(total_amt_usd) total_amt
  FROM (SELECT *
          FROM orders
          WHERE (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
                   FROM orders)
                 = DATE_TRUNC('month', occurred_at)) AS first_month_data;

/* Name of the sales_rep in each region with the largest amount of total_amt_usd sales.
   - 1st Subquery: sales rep, its region, and its total sales */
SELECT r.name "Region", sr.name "Rep", SUM(o.total_amt_usd) "$ Total Sales"
  FROM sales_reps sr
  JOIN accounts a
  ON sr.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  JOIN region r
  ON r.id = sr.region_id
  GROUP BY 1, 2
  ORDER BY 1, 3 DESC;

/* - 2nd Subquery: region and its max total sales from the 1st Subquery */
SELECT "Region", MAX("$ Total Sales") "Max $ Total Sales"
  FROM (SELECT r.name "Region", sr.name "Rep", SUM(o.total_amt_usd) "$ Total Sales"
          FROM sales_reps sr
          JOIN accounts a
          ON sr.id = a.sales_rep_id
          JOIN orders o
          ON a.id = o.account_id
          JOIN region r
          ON r.id = sr.region_id
          GROUP BY 1, 2) sub1
  GROUP BY 1;

/* Final Query: the JOIN of the 2 above where the amount matches */
SELECT sub2."Region", sub1."Rep", sub2."Max $ Total Sales"
  FROM (SELECT r.name "Region", sr.name "Rep", SUM(o.total_amt_usd) "$ Total Sales"
          FROM sales_reps sr
          JOIN accounts a
          ON sr.id = a.sales_rep_id
          JOIN orders o
          ON a.id = o.account_id
          JOIN region r
          ON r.id = sr.region_id
          GROUP BY 1, 2) sub1
  JOIN (SELECT "Region", MAX("$ Total Sales") "Max $ Total Sales"
          FROM (SELECT r.name "Region", sr.name "Rep", SUM(o.total_amt_usd) "$ Total Sales"
                  FROM sales_reps sr
                  JOIN accounts a
                  ON sr.id = a.sales_rep_id
                  JOIN orders o
                  ON a.id = o.account_id
                  JOIN region r
                  ON r.id = sr.region_id
                  GROUP BY 1, 2) sub1
          GROUP BY 1;) sub2
  ON sub1."Region" = sub2."Region" AND sub1."$ Total Sales" = sub2."Max $ Total Sales";

/* For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
   - Inner Query: region with the highest total sum of sales */
SELECT r.name "Region",
       SUM(o.total_amt_usd) "$ Total"
  FROM region r
  JOIN sales_reps sr
  ON r.id = sr.region_id
  JOIN accounts a
  ON sr.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1;

/* Outer Query: total number of orders for the resulting region above */
SELECT r.name "Region", COUNT(*) "Total Orders"
  FROM region r
  JOIN sales_reps sr
  ON r.id = sr.region_id
  JOIN accounts a
  ON sr.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  HAVING r.name =
    (SELECT reg_name
       FROM (SELECT r.name reg_name,
                    SUM(o.total_amt_usd) "$ Total"
               FROM region r
               JOIN sales_reps sr
               ON r.id = sr.region_id
               JOIN accounts a
               ON sr.id = a.sales_rep_id
               JOIN orders o
               ON a.id = o.account_id
               GROUP BY 1
               ORDER BY 2 DESC
               LIMIT 1) sub_query);

/* For the name of the account that purchased the most (in total over their lifetime as a customer) standard_qty paper,
   how many accounts still had more in total purchases?
   Inner Query: account that has purchased the largest quantity of standard paper */
SELECT a.name account_name, SUM(o.standard_qty) tot_std_qty, SUM(o.total) tot_qty
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1;

/* - 1st Outer Query: accounts that have purchased more paper of all types than the resulting account above */
SELECT a.name account_name, SUM(o.standard_qty) tot_std_qty, SUM(o.total) tot_qty
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) >
         (SELECT tot_qty
            FROM (SELECT a.name account_name, SUM(o.standard_qty) tot_std_qty, SUM(o.total) tot_qty
                    FROM accounts a
                    JOIN orders o
                    ON a.id = o.account_id
                    GROUP BY 1
                    ORDER BY 2 DESC
                    LIMIT 1) sub_query)
    ORDER BY 3 DESC;

/* - 2nd Outer Query: number of results in the query above */
SELECT COUNT(*)
  FROM (SELECT a.name account_name, SUM(o.standard_qty) tot_std_qty, SUM(o.total) tot_qty
          FROM accounts a
          JOIN orders o
          ON a.id = o.account_id
          GROUP BY 1
          HAVING SUM(o.total) >
                 (SELECT tot_qty
                    FROM (SELECT a.name account_name, SUM(o.standard_qty) tot_std_qty, SUM(o.total) tot_qty
                            FROM accounts a
                            JOIN orders o
                            ON a.id = o.account_id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) sub_query)
       ) outer_query;

/* For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
   how many web_events did they have for each channel?
   Inner Query: customer that spent the most */
SELECT a.id id, a.name customer, SUM(o.total_amt_usd) total_spent
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 1;

/* 1st Outer Query: web events and channels for the resulting account above */
SELECT we.channel channel, we.id web_event
  FROM web_events we
  WHERE we.account_id =
        (SELECT id
           FROM (SELECT a.id id,
                        a.name customer,
                        SUM(o.total_amt_usd) total_spent
                   FROM accounts a
                   JOIN orders o
                   ON a.id = o.account_id
                   GROUP BY 1, 2
                   ORDER BY 3 DESC
                   LIMIT 1) sub_query);

/* 2nd Outer Query: number of web events for each resulting channel above */
SELECT channel "Channel", COUNT(*) "Number of Web Events"
  FROM (SELECT we.channel channel, we.id web_event
         FROM web_events we
         WHERE we.account_id =
               (SELECT id
                  FROM (SELECT a.id id,
                               a.name customer,
                               SUM(o.total_amt_usd) total_spent
                          FROM accounts a
                          JOIN orders o
                          ON a.id = o.account_id
                          GROUP BY 1, 2
                          ORDER BY 3 DESC
                          LIMIT 1) sub_query)) outer_query
  GROUP BY 1
  ORDER BY 2 DESC;

/* ALTERNATIVE SOLUTION FROM THE COURSE CORRECTION (only 1 outer query): */
SELECT a.name "Account", we.channel "Channel", COUNT(*) "/* Web Events"
  FROM accounts a
  JOIN web_events we
  ON a.id = we.account_id AND
     a.id = (SELECT id
               FROM (SELECT a.id id,
                            a.name customer,
                            SUM(o.total_amt_usd) total_spent
                       FROM accounts a
                       JOIN orders o
                       ON a.id = o.account_id
                       GROUP BY 1, 2
                       ORDER BY 3 DESC
                       LIMIT 1) sub_query)
  GROUP BY 1, 2
  ORDER BY 3 DESC;

/* What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
   Inner Query : top 10 total spending accounts */
SELECT a.id, a.name, SUM(o.total_amt_usd)
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 10;

/* Outer Query : average of the 10 amounts above */
SELECT AVG(sub_query.total_spent) "TOP 10 average $"
  FROM (SELECT a.id, SUM(o.total_amt_usd) total_spent
          FROM accounts a
          JOIN orders o
          ON a.id = o.account_id
          GROUP BY 1
          ORDER BY 2 DESC
          LIMIT 10) sub_query;

/* What is the lifetime average amount spent in terms of total_amt_usd
   for only the companies that spent more than the average of all orders.
   1st Inner Query: average of all orders */
SELECT AVG(total_amt_usd)
  FROM orders;

/* 2nd Inner Query: accounts that spent more on average than the average above */
SELECT a.name company, AVG(o.total_amt_usd) avg_spent
  FROM accounts a
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1
  HAVING AVG(o.total_amt_usd) >
         (SELECT AVG(total_amt_usd)
            FROM orders)
  ORDER BY 2 DESC;

/* Outer Query: average of the resulting totals above */
SELECT AVG(avg_spent)
  FROM (SELECT a.name company, AVG(o.total_amt_usd) avg_spent
          FROM accounts a
          JOIN orders o
          ON a.id = o.account_id
          GROUP BY 1
          HAVING AVG(o.total_amt_usd) >
                 (SELECT AVG(total_amt_usd)
                    FROM orders)) sub_query;

/*** WITH
     same 6 examples as above

   name of the sales_rep in each region with the largest amount of total_amt_usd sales */
WITH rep_reg_tot_amt AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1,2),
  
    reg_max_amt AS (
      SELECT region_name, MAX(total_amt) max_amt
        FROM rep_reg_tot_amt
        GROUP BY 1)

SELECT rep_reg_tot_amt.rep_name, reg_max_amt.region_name, reg_max_amt.max_amt
  FROM rep_reg_tot_amt
  JOIN reg_max_amt
  ON rep_reg_tot_amt.region_name = reg_max_amt.region_name AND
     rep_reg_tot_amt.total_amt = reg_max_amt.max_amt;

/* For the region with the largest sales total_amt_usd, how many total orders were placed? */
WITH reg_tot_usd AS (
  SELECT r.name region_name, SUM(o.total_amt_usd) total_usd
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY r.name),

      reg_max_usd AS (
        SELECT MAX(total_usd) max_usd
          FROM reg_tot_usd)

SELECT r.name, COUNT(o.total) total_orders
  FROM sales_reps s
  JOIN accounts a
  ON a.sales_rep_id = s.id
  JOIN orders o
  ON o.account_id = a.id
  JOIN region r
  ON r.id = s.region_id
  GROUP BY r.name
  HAVING SUM(o.total_amt_usd) =
         (SELECT max_usd
          FROM reg_max_usd);

/* For the name of the account that purchased the most standard_qty paper,
   how many accounts still had more in total purchases? */
WITH acc_most_std_qty AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1),

     acc_more_tot_qty AS (
  SELECT a.name
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY 1
    HAVING SUM(o.total) >
           (SELECT total 
              FROM acc_most_std_qty))

SELECT COUNT(*) FROM acc_more_tot_qty;

/* For the customer that spent the most total_amt_usd,
   how many web_events did they have for each channel? */
WITH acc_most_usd AS (
  SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY 3 DESC
    LIMIT 1)

SELECT a.name, w.channel, COUNT(*)
  FROM accounts a
  JOIN web_events w
  ON a.id = w.account_id AND
     a.id =  (SELECT id FROM acc_most_usd)
  GROUP BY 1, 2
  ORDER BY 3 DESC;

/* What is the lifetime average amount spent in terms of total_amt_usd
   for the top 10 total spending accounts? */
WITH top_10_spenders AS (
  SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY 3 DESC
    LIMIT 10)

SELECT AVG(tot_spent) FROM top_10_spenders;

/* What is the lifetime average amount spent in terms of total_amt_usd
   for only the companies that spent more than the average of all accounts. */
WITH avg_usd AS (
  SELECT AVG(o.total_amt_usd) avg_all
    FROM orders o
    JOIN accounts a
    ON a.id = o.account_id),

     acc_over_avg_usd AS (
  SELECT o.account_id, AVG(o.total_amt_usd) avg_tot_usd
    FROM orders o
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (SELECT avg_all FROM avg_usd))

SELECT AVG(avg_tot_usd) FROM acc_over_avg_usd;

/*** LEFT & RIGHT
  Pull extensions from each account's website and provide how many of each type. */
SELECT RIGHT(website, 3) web_ext, COUNT(*) num_extensions
  FROM accounts
  GROUP BY 1
  ORDER BY 2 DESC;

/* Distribution of company names by 1st letter */
SELECT UPPER(LEFT(name, 1)) first_letter, COUNT(*) num_first
  FROM accounts
  GROUP BY 1
  ORDER BY 2 DESC;

/* Ratio of companies whose names start with a letter vs a number */
WITH alphas_nums AS (
  SELECT CASE WHEN LEFT(UPPER(name), 1) BETWEEN '0' AND '9'
                THEN 1 ELSE 0 END AS nums, 
         CASE WHEN LEFT(UPPER(name), 1) BETWEEN '0' AND '9' 
                THEN 0 ELSE 1 END AS letters
      FROM accounts),
     alpha_num_counts AS (
  SELECT SUM(letters) num_letters, SUM(nums) num_nums FROM alphas_nums)

SELECT CAST(num_letters AS float) / CAST((num_letters + num_nums) AS float) "Percent Letters"
  FROM alpha_num_counts;

/* Ratio of companies whose names start with a vowel vs other */
WITH vowels_others AS (
  SELECT CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U')
                THEN 1 ELSE 0 END AS vowels, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U')
                THEN 0 ELSE 1 END AS others
      FROM accounts),
     vowel_counts AS (
  SELECT SUM(vowels) num_vowels, SUM(others) num_others FROM vowels_others)

SELECT CAST(num_vowels AS float) / CAST((num_vowels + num_others) AS float) "Percent Vowels"
  FROM vowel_counts;

/*** POSITION & STRPOS
  First and last names for accounts.primary_poc */
SELECT
  LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name,
  RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name
FROM accounts;

/* Same for sales reps */
SELECT
  LEFT(name, POSITION(' ' IN name) - 1) first_name,
  RIGHT(name, LENGTH(name) - POSITION(' ' IN name)) last_name
FROM sales_reps;

/*** CONCAT & ||
  e-mail address for each account = first name of the primary_poc . last name primary_poc @ company name .com */
WITH company_poc AS (
  SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name,
         RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name,
         name
    FROM accounts)

SELECT LOWER(CONCAT(first_name, '.', last_name, '@', name, '.com')) e_mail
  FROM company_poc;

/* Same as above, but remove spaces from company names */
WITH company_poc AS (
  SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1) first_name,
         RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name,
         name
    FROM accounts)

SELECT REPLACE(LOWER(CONCAT(first_name, '.', last_name, '@', name, '.com')), ' ', '') e_mail
  FROM company_poc;

/* password = 1st letter of primary_poc's first name (lowercase) + last letter of their first name (lowercase)
            + first letter of their last name (lowercase) + last letter of their last name (lowercase)
            + number of letters in their first name + number of letters in their last name
            + name of the company they are working with, all capitalized with no spaces */
WITH company_poc AS (
  SELECT LOWER(LEFT(primary_poc, POSITION(' ' IN primary_poc) - 1)) first_name,
         LOWER(RIGHT(primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc))) last_name,
         UPPER(REPLACE(name, ' ', '')) company
    FROM accounts)

SELECT CONCAT(LEFT(first_name, 1), RIGHT(first_name, 1),
              LEFT(last_name, 1), RIGHT(last_name, 1),
              LENGTH(first_name), LENGTH(last_name),
              company) "Password"
  FROM company_poc;

/*** CAST
  change the date into the correct SQL date format and cast it to a date (CAST or ::) */
WITH day_time AS (
  SELECT SUBSTR(date, 1, 2) date_month,
         SUBSTR(date, 4, 2) date_day,
         SUBSTR(date, 7, 4) date_year,
         RIGHT(date, 18) date_time
    FROM sf_crime_data),

     correct_day_time AS (
       SELECT CONCAT(date_year, '-', date_month, '-', date_day, ' ', date_time) new_date
         FROM day_time)

SELECT sf_crime_data.date incorrect_format,
       correct_day_time.new_date correct_format
  FROM sf_crime_data, correct_day_time
  LIMIT 1;

/*** COALESCE
  fill in NULL accounts.id and orders.account_id with account.id, and all quantities with 0 */
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
       COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty,
       COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total,
       COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
       COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

/* Remove WHERE and count the number of IDs: 6913 */
SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

/* Final result: 1st query with the WHERE removed */
SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id,
       COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty,
       COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total,
       COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd,
       COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;