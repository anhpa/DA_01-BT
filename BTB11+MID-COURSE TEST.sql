--1.Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and their respective average city populations (CITY.Population) rounded down to the nearest integer

select COUNTRY.Continent, 
FLOOR(AVG(CITY.Population))
from CITY
INNER JOIN COUNTRY 
ON CITY.CountryCode=COUNTRY.Code
GROUP BY COUNTRY.Continent

--2.A senior analyst is interested to know the activation rate of specified users in the emails table. Write a query to find the activation rate. Round the percentage to 2 decimal places.
--KQ = 1 (Wrong answer - kq đúng = 0.33)

SELECT
round((count(texts.signup_action)/COUNT(emails.user_id)),2) AS confirm_rate
FROM emails
LEFT JOIN texts 
ON emails.email_id=texts.email_id
WHERE texts.signup_action='Confirmed'

--3.Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.
--Báo lỗi khi insert thêm hàm round

SELECT ab.age_bucket,
  sum(case when activity_type ='send' THEN time_spent else 0 end) AS t_send,
  sum(case when activity_type ='open' then time_spent else 0 end) AS t_open,
ROUND(t_send/(t_send+t_open)*100.0,2) as send_perc,
ROUND(t_open/(t_send+t_open)*100.0,2) as open_perc,
FROM activities AS a
LEFT JOIN age_breakdown as ab
on ab.user_id=a.user_id
GROUP BY ab.age_bucket

---Bài sửa
SELECT 
  age.age_bucket, 
 ROUND(100.0 * SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'send')/ SUM(activities.time_spent),2) AS send_perc, 
 ROUND(100.0 * SUM(activities.time_spent) FILTER (WHERE activities.activity_type = 'open')/SUM(activities.time_spent),2) AS open_perc
FROM activities
INNER JOIN age_breakdown AS age 
  ON activities.user_id = age.user_id 
WHERE activities.activity_type IN ('send', 'open') 
GROUP BY age.age_bucket

--4.Write a query that effectively identifies the company ID of such Supercloud customers.
--Báo lỗi khi insert thêm hàm CT

SELECT c.customer_id,p.product_category,
COUNT(p.product_category)=COUNT(DISTINCT p.product_category)
FROM customer_contracts as c 
LEFT JOIN products AS p on c.product_id=p.product_id
GROUP BY c.customer_id,p.product_name,product_category

--5.Write a solution to report the ids and the names of all managers, the number of employees who report directly to them, and the average age of the reports rounded to the nearest integer. Return the result table ordered by employee_id.
--Không điều chỉnh được tên cột age

SELECT
emp.employee_id,emp.name as name, 
count(emp.reports_to) as reports_count, 
round((avg(emp.age)),0) as age
from Employees as emp
left join Employees as mng ON emp.employee_id=mng.employee_id
order by emp.employee_id

--6.Write a solution to get the names of products that have at least 100 units ordered in February 2020 and their amount.

select 
p.product_name as product_name,sum(o.unit) as unit
from Products as p
join Orders as o ON p.product_id=o.product_id
where EXTRACT(month from order_date)=2 and EXTRACT(year from order_date) = 2020
group by p.product_name
having unit>=100

--7. Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

SELECT p.page_id as page_id
FROM pages AS p
LEFT JOIN page_likes as pl ON p.page_id=pl.page_id
WHERE liked_date is NULL
ORDER BY p.page_id 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--MID-COURSE TEST
--1. Tạo danh sách tất cả chi phí thay thế (replacement costs )  khác nhau của các film. Chi phí thay thế thấp nhất là bao nhiêu?

select distinct film_id,
min(replacement_cost) as min_replacement_cost
from film
group by film_id
order by min(replacement_cost)
limit 1

--2. Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau - low: 9.99 - 19.99
/medium: 20.00 - 24.99 / high: 25.00 - 29.99. 
--Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”? 
-- Lỗi lúc sử dụng hàm count

select film_id,replacement_cost,
CASE
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 then 'LOW'
	WHEN replacement_cost BETWEEN 20.00 AND 24.99 then 'MEDIUM'
	ELSE 'HIGH'
END AS category
from film
group by film_id

--3. Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và tên danh mục (category_name) được sắp xếp theo độ dài giảm dần. Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'. 
--Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?


select a.title,a.length,c.name
from film as a
join film_category as b ON a.film_id=b.film_id
join category as c ON b.category_id=c.category_id
where c.name in ('Sports','Drama')
group by a.title,a.length,c.name
order by a.length desc
limit 1

--4.Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category). 
--Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?


select c.name,
count(a.title) as so_luong_phim
from film as a
join film_category as b ON a.film_id=b.film_id
join category as c ON b.category_id=c.category_id
group by c.name
order by count(a.title) desc
limit 1

--5. Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên cũng như số lượng phim họ tham gia. 
--Question: Diễn viên nào đóng nhiều phim nhất?

select
a1.first_name || ' ' || a1.last_name as ten_DV,count(a2.film_id) as so_luong_phim
from actor as a1
join film_actor as a2 on a1.actor_id=a2.actor_id
group by a1.first_name || ' ' || a1.last_name
order by count(a2.film_id) desc
limit 1

--6.Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào. 
--Question: Có bao nhiêu địa chỉ như vậy?
--Lỗi sử dụng hàm count

select a2.customer_id, a1.address,
COUNT(*) AS count_record
from address as a1
left join customer as a2 on a1.address_id=a2.address_id
where a2.customer_id is null 
group by a2.customer_id, a1.address

--7. Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố 
--Question:Thành phố nào đạt doanh thu cao nhất?

SELECT a4.city,sum(a1.amount)
FROM payment as a1
join customer as a2 on a1.customer_id=a2.customer_id
join address as a3 on a2.address_id=a3.address_id
join city as a4 on a3.city_id=a4.city_id
group by a4.city
order by sum(a1.amount) desc
limit 1

--8.Task: Tạo danh sách trả ra 2 cột dữ liệu: 
--cột 1: thông tin thành phố và đất nước ( format: “city, country")
--cột 2: doanh thu tương ứng với cột 1
--Question: thành phố của đất nước nào đat doanh thu cao nhất
-- Answer: United States, Tallahassee : 50.85. (theo như dữ liệu sort ra thì đây là thành phố có doanh thu thấp nhất)

SELECT a4.city||','||a5.country as tp_dn,
sum(a1.amount)
FROM payment as a1
join customer as a2 on a1.customer_id=a2.customer_id
join address as a3 on a2.address_id=a3.address_id
join city as a4 on a3.city_id=a4.city_id
join country as a5 on a4.country_id=a5.country_id
group by a4.city||','||a5.country
order by sum(a1.amount) desc
limit 1


