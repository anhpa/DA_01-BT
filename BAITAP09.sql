-- 1.Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership. Output the total viewership for laptops as laptop_reviews and the total viewership for mobile devices as mobile_views.

SELECT  
SUM(CASE
 WHEN device_type='laptop' THEN 1 else 0
 END) AS laptop_reviews,
SUM(CASE
 WHEN device_type IN ('tablet', 'phone')  THEN 1 ELSE 0
 END) AS mobile_views
FROM viewership

-- 2. Report for every three line segments whether they can form a triangle. Return the result table in any order.

SELECT x,y,z,
CASE
 WHEN x+y>z and y+z>x and x+z>y THEN 'Yes'
 ELSE 'No'
 END AS triangle
 FROM Triangle

-- 3. Write a query to find the percentage of calls that cannot be categorised. Round your answer to 1 decimal place. ( error: division by zero)

SELECT 
round(SUM(CASE
 WHEN call_category='n/a' OR call_category is NULL THEN 1 ELSE 0 
 END)/COUNT(case_id)*100,1) as call_percentage
FROM callers

-- 4. Find the names of the customer that are not referred by the customer with id = 2. Return the result table in any order.

select name from Customer
where referee_id <>2 or referee_id is null

-- 5.Output the number of survivors and non-survivors by each class.

select survived,
sum(case 
when pclass = 1 then 1 else 0
end) as first_class,
sum(case 
when pclass = 2 then 1 else 0
end) as second_classs,
sum(case 
when pclass = 3 then 1 else 0
end) as third_class
from titanic
group by survived
