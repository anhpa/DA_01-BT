-- 1.Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by the last three characters of each name. If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.

Input Format
select name from STUDENTS 
where marks >75
order by right(name,3), id asc

-- 2.Write a solution to fix the names so that only the first character is uppercase and the rest are lowercase. Return the result table ordered by user_id.

select user_id,
concat(upper(left(name,1)),lower(substring(name,2))) as name
from Users
order by user_id

-- 3.Write a query to calculate the total drug sales for each manufacturer. Round the answer to the nearest million and report your results in descending order of total sales. In case of any duplicates, sort them alphabetically by the manufacturer name.

SELECT manufacturer,
concat('$',round(sum(total_sales)/1000000,0),' ','million') as sale
FROM pharmacy_sales
GROUP BY manufacturer
order by sum(total_sales) desc, manufacturer

-- 4.Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. Sort the output first by month and then by product ID.

SELECT 
EXTRACT(month from submit_date) as mth, 
product_id as product, 
ROUND(AVG(stars),2) as avg_stars
FROM reviews
GROUP BY EXTRACT(month from submit_date), product_id
ORDER BY mth , product_id

-- 5.Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending order based on the count of the messages.

SELECT sender_id,
COUNT(message_id) as message_count
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-09-01'
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
limit 2

-- 6.Write a solution to find the IDs of the invalid tweets. The tweet is invalid if the number of characters used in the content of the tweet is strictly greater than 15.Return the result table in any order.

select tweet_id from Tweets
where length(content)>15
order by tweet_id

-- 7.Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. A user was active on someday if they made at least one activity on that day.

select activity_date as day,
count(distinct user_id) as active_users
from Activity
where activity_date BETWEEN '2019-06-28' AND '2019-07-27'
group by activity_date

-- 8.You have been asked to find the number of employees hired between the months of January and July in the year 2022 inclusive.

select 
count(id) as number_of_employees
from employees 
where joining_date between '2022-01-01' and '2022-08-01'

-- 9.Find the position of the lower case letter 'a' in the first name of the worker 'Amitah'.

select position('a' in first_name)
from worker
where first_name ='Amitah'

-- 10. Find the vintage years of all wines from the country of Macedonia. The year can be found in the 'title' column. Output the wine (i.e., the 'title') along with the year. The year should be a numeric or int data type.

select substring(title from position('2' in title) for 4),
title 
from winemag_p2
where country = 'Macedonia'
