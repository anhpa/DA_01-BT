--B04BT1
SELECT DISTINCT CITY FROM STATION 
WHERE ID%2 = 0
--B04BT2
SELECT (COUNT(CITY)- COUNT(DISTINCT CITY)) AS difference
FROM STATION 
--B04BT4
select 
ROUND(CAST(SUM(item_count * order_occurrences)/SUM(order_occurrences) AS DECIMAL),1) as mean
from items_per_order
--B04BT5
SELECT candidate_id FROM candidates
WHERE skill IN ('Python','Tableau','PostgreSQL') 
GROUP BY candidate_id
HAVING COUNT(skill)=3
--B04BT6
SELECT user_id,
max(date(post_date))-min(date(post_date)) AS days_between
FROM posts
WHERE date(post_date)>='2021-01-01'AND date(post_date)<'2022-01-01'
GROUP BY user_id
HAVING COUNT(user_id)>=2
--B04BT7
SELECT card_name, MAX(issued_amount)-MIN(issued_amount) AS difference_number_issued_cards
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference_number_issued_cards DESC
--B04BT8
SELECT manufacturer,
COUNT(drug) as drug_count,
sum(cogs - total_sales) AS total_loss
FROM pharmacy_sales
WHERE cogs>total_sales
GROUP BY manufacturer
ORDER BY total_loss DESC
--B04BT9
SELECT * FROM Cinema
WHERE id%2 <> 0 AND description NOT LIKE 'BORING'
ORDER BY rating DESC
--B04BT10
select teacher_id, 
COUNT(DISTINCT subject_id) as cnt
from Teacher
group by teacher_id
--B04BT11
SELECT user_id,
COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id 
--B04BT12
SELECT class FROM Courses
GROUP BY class
HAVING COUNT(DISTINCT student)>=5
