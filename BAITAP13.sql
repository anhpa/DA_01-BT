--1. Assume you're given a table containing job postings from various companies on the LinkedIn platform. Write a query to retrieve the count of companies that have posted duplicate job listings.

--Definition: Duplicate job listings are defined as two job listings within the same company that share identical titles and descriptions.

WITH job_count_cte AS
  (SELECT company_id, title, description, 
  COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description)

SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM job_count_cte
WHERE job_count >1

--2. Assume you're given a table containing data on Amazon customers and their spending on products in different category, write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include the category, product, and total spend

WITH product_retail AS 
(SELECT category, product,sum(spend) as total_spend,
(RANK() OVER (
PARTITION BY category
ORDER BY sum(spend) DESC))AS ranking
FROM product_spend
WHERE EXTRACT( 'year' FROM transaction_date) =2022
GROUP BY category, product)

SELECT category, product,total_spend FROM product_retail
WHERE ranking<=2

--3. Write a query to find how many UHG members made 3 or more calls. case_id column uniquely identifies each call made.

WITH call_record AS
(SELECT policy_holder_id, count(case_id) as so_luong FROM callers
GROUP BY policy_holder_id
HAVING count(case_id)>=3)

SELECT COUNT(so_luong) as member_count FROM call_record

--4. Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

WITH a12 AS
(SELECT pl.liked_date,p.page_id as page_id
FROM pages AS p
LEFT JOIN page_likes as pl ON p.page_id=pl.page_id)

SELECT page_id FROM a12
WHERE liked_date is NULL
ORDER BY page_id 

--5. Assume you're given a table containing information on Facebook user actions. Write a query to obtain number of monthly active users (MAUs) in July 2022, including the month in numerical format "1, 2, 3".

WITH result1 as 
(select t7.month, t7.user_id

FROM (SELECT DISTINCT user_id,event_type,
EXTRACT(month FROM event_date) as month
FROM user_actions
WHERE event_type is NOT NUll and EXTRACT(month FROM event_date)=7 and 
EXTRACT(year FROM event_date)=2022
ORDER BY month) as t7

INNER JOIN (SELECT DISTINCT user_id,event_type,
EXTRACT(month FROM event_date) as month1 
FROM user_actions
WHERE event_type is NOT NUll and EXTRACT(month FROM event_date)=6 and 
EXTRACT(year FROM event_date)=2022
ORDER BY month1) as t6

on t7.user_id=t6.user_id
GROUP BY t7.month, t7.user_id)

SELECT month, COUNT(*) AS monthly_active_users FROM result1
GROUP BY month

--6. Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.

select t1.month,t1.country,t2.trans_count,t1.approved_count,t2.trans_total_amount,t1.approved_total_amount
from (SELECT id,
SUBSTR(trans_date,1,7) as 'month',country,
count(trans_date) as approved_count, state,
sum(amount) as approved_total_amount from Transactions
where state like 'approved'
group by month,country) as t1
inner join (SELECT id,
SUBSTR(trans_date,1,7) as 'month',country,
count(trans_date) as trans_count, state,
sum(amount) as trans_total_amount from Transactions
group by month,country) as t2 on t1.id=t2.id
group by month,country

--7.Write a solution to select the product id, year, quantity, and price for the first year of every product sold. Return the resulting table in any order.

select product_id, min(year) as first_year, quantity, price
from sales
GROUP BY product_id

--8. Write a solution to report the customer ids from the Customer table that bought all the products in the Product table.

select customer_id
from Customer 
group by customer_id 
having COUNT(distinct product_key) = (SELECT COUNT(product_key) FROM Product)

--9. Find the IDs of the employees whose salary is strictly less than $30000 and whose manager left the company. When a manager leaves the company, their information is deleted from the Employees table, but the reports still have their manager_id set to the manager that left.

select employee_id
from Employees
where salary<30000 and manager_id not in (select employee_id from Employees group by employee_id)
order by employee_id

--10. Assume you're given a table containing job postings from various companies on the LinkedIn platform. Write a query to retrieve the count of companies that have posted duplicate job listings.

WITH job_count_cte AS
  (SELECT company_id, title, description, 
  COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY company_id, title, description)

SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM job_count_cte
WHERE job_count >1

--11. Write a solution to:
--Find the name of the user who has rated the greatest number of movies. In case of a tie, return the lexicographically smaller user name.
--Find the movie name with the highest average rating in February 2020. In case of a tie, return the lexicographically smaller movie name.

(select a1.name as results
from Users as a1
join MovieRating as a2 on a1.user_id=a2.user_id
group by a1.name
order by count(rating) desc
limit 1)
union all
(select a3.title as results
from Movies as a3
join MovieRating as a2 on a2.movie_id=a3.movie_id 
where SUBSTR(a2.created_at,1,7)='2020-02'
group by a3.title
order by AVG(rating) desc, a3.title asc
limit 1)

--12.Write a solution to find the people who have the most friends and the most friends number.

SELECT DISTINCT requester_id 
AS id, 
COUNT(*) AS num

FROM(SELECT requester_id, accepter_id   
FROM RequestAccepted
UNION
SELECT accepter_id, requester_id 
FROM RequestAccepted) as a1
GROUP BY requester_id
ORDER BY num DESC
LIMIT 1


